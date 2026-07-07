package com.attendance.service;

import com.attendance.dao.StudentDao;
import com.attendance.model.Student;
import com.attendance.util.JDBCUtil;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.io.*;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

import static org.apache.poi.ss.usermodel.CellType.*;

public class StudentService {
    private StudentDao studentDao = new StudentDao();

    public List<Student> getAllStudents() { return studentDao.getAllStudents(); }
    public Student findByStudentId(String studentId) { return studentDao.findByStudentId(studentId); }
    public boolean addStudent(Student s) { return studentDao.addStudent(s); }
    public boolean updateStudent(Student s) { return studentDao.updateStudent(s); }
    public boolean deleteStudent(String sid) { return studentDao.deleteStudent(sid); }
    public int deleteAll() { return studentDao.deleteAll(); }
    public int deleteByClass(String className) { return studentDao.deleteByClass(className); }
    public int countAll() { return studentDao.countAll(); }

    public Map<String, Object> batchImport(List<Student> students) {
        Map<String, Object> result = new HashMap<>();
        int success = 0, fail = 0, dup = 0;
        Set<String> seen = new HashSet<>();
        Connection conn = null;
        try {
            conn = JDBCUtil.getConnection();
            conn.setAutoCommit(false);
            for (Student s : students) {
                if (s.getStudentId() == null || s.getStudentId().trim().isEmpty()
                        || s.getName() == null || s.getName().trim().isEmpty()) {
                    fail++; continue;
                }
                // 本次导入中重复检测
                if (seen.contains(s.getStudentId())) { dup++; continue; }
                seen.add(s.getStudentId());
                // 数据库中已有学号检测
                if (studentDao.findByStudentId(s.getStudentId()) != null) { dup++; continue; }
                try { studentDao.addStudent(conn, s); success++; }
                catch (SQLException e) { fail++; }
            }
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) {} }
            result.put("error", e.getMessage()); return result;
        } finally {
            if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException e) {} JDBCUtil.close(conn, null, null); }
        }
        result.put("success", success);
        result.put("fail", fail);
        result.put("dup", dup);
        return result;
    }

    public List<Student> parseExcel(InputStream is, String fileName) throws IOException {
        List<Student> list = new ArrayList<>();
        Workbook wb;
        try {
            wb = fileName.endsWith(".xlsx") ? new XSSFWorkbook(is) : new HSSFWorkbook(is);
        } catch (Exception e) {
            throw new IOException("无法读取Excel文件，请确认文件格式正确且未加密: " + e.getMessage());
        }
        Sheet sheet = wb.getSheetAt(0);
        if (sheet == null) { wb.close(); return list; }

        // 获取列数（前3行最大列数）自动适配
        int maxCols = 0;
        for (int r = 0; r <= Math.min(sheet.getLastRowNum(), 2); r++) {
            Row row = sheet.getRow(r);
            if (row != null && row.getLastCellNum() > maxCols) maxCols = row.getLastCellNum();
        }
        if (maxCols < 2) maxCols = 3;

        int start = 0;
        boolean hasGender = false;
        Row hdr = sheet.getRow(0);
        if (hdr != null) {
            String firstCell = getStr(hdr.getCell(0)).trim();
            if ("学号".equals(firstCell) || "姓名".equals(firstCell)
                    || "student_id".equalsIgnoreCase(firstCell) || "name".equalsIgnoreCase(firstCell)) {
                start = 1;
                for (int c = 0; c < maxCols; c++) {
                    if ("性别".equals(getStr(hdr.getCell(c)).trim())) { hasGender = true; break; }
                }
            }
        }

        for (int i = start; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;

            String sid = getStr(row.getCell(0)).trim();
            String name = getStr(row.getCell(1)).trim();
            // 全空行跳过
            if (sid.isEmpty() && name.isEmpty()) {
                // 检测该行是否全为空
                boolean allEmpty = true;
                for (int c = 0; c < maxCols; c++) {
                    if (!getStr(row.getCell(c)).trim().isEmpty()) { allEmpty = false; break; }
                }
                if (allEmpty) continue;
            }

            String gender, cls;
            if (hasGender || maxCols >= 4) {
                gender = getStr(row.getCell(2)).trim();
                cls = getStr(row.getCell(3)).trim();
            } else {
                cls = getStr(row.getCell(2)).trim();
                gender = "";
            }
            if (!sid.isEmpty() || !name.isEmpty())
                list.add(new Student(sid, name, gender, cls));
        }
        wb.close(); return list;
    }

    public List<Student> parseText(InputStream is) throws IOException {
        List<Student> list = new ArrayList<>();
        BufferedReader r = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        String line = r.readLine();
        if (line != null && !line.trim().startsWith("学号")) parseLine(line, list);
        while ((line = r.readLine()) != null) parseLine(line, list);
        r.close(); return list;
    }

    private void parseLine(String line, List<Student> list) {
        line = line.trim(); if (line.isEmpty()) return;
        String sep = line.contains("\t") ? "\t" : (line.contains(";") ? ";" : ",");
        String[] p = line.split(sep, -1);
        // 4列: 学号,姓名,性别,班级   3列(兼容): 学号,姓名,班级
        if (p.length >= 2 && !p[0].trim().isEmpty()) {
            String sid = p[0].trim(), name = p[1].trim();
            String gender = p.length >= 4 ? p[2].trim() : "";
            String cls = p.length >= 4 ? p[3].trim() : (p.length >= 3 ? p[2].trim() : "");
            list.add(new Student(sid, name, gender, cls));
        }
    }

    private static String getStr(Cell cell) {
        if (cell == null) return "";
        try {
            switch (cell.getCellType()) {
                case STRING:
                    return cell.getStringCellValue();
                case NUMERIC:
                    if (DateUtil.isCellDateFormatted(cell)) {
                        return new java.text.SimpleDateFormat("yyyy-MM-dd").format(cell.getDateCellValue());
                    }
                    double v = cell.getNumericCellValue();
                    if (v == Math.floor(v) && !Double.isInfinite(v))
                        return String.valueOf((long) v);
                    return String.valueOf(v);
                case BOOLEAN:
                    return String.valueOf(cell.getBooleanCellValue());
                case FORMULA:
                    // 尝试获取公式计算结果的值
                    try {
                        DataFormatter df = new DataFormatter();
                        return df.formatCellValue(cell);
                    } catch (Exception e) {
                        return cell.getStringCellValue();
                    }
                case BLANK:
                    return "";
                default:
                    return "";
            }
        } catch (Exception e) {
            return "";
        }
    }
}
