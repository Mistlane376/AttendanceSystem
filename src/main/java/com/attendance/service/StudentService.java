package com.attendance.service;

import com.attendance.dao.StudentDao;
import com.attendance.model.Student;
import com.attendance.util.JDBCUtil;
import org.apache.poi.ss.usermodel.*;
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
        Workbook wb = fileName.endsWith(".xlsx") ? new XSSFWorkbook(is) : new HSSFWorkbook(is);
        Sheet sheet = wb.getSheetAt(0);
        int start = 0;
        boolean hasGender = false;  // 是否包含性别列
        Row hdr = sheet.getRow(0);
        if (hdr != null && hdr.getCell(0) != null) {
            String v = getStr(hdr.getCell(0));
            if ("学号".equals(v) || "姓名".equals(v) || "name".equalsIgnoreCase(v)) {
                start = 1;
                // 检测表头是否有"性别"列
                for (int c = 0; c <= 3; c++) {
                    if ("性别".equals(getStr(hdr.getCell(c)).trim())) { hasGender = true; break; }
                }
            }
        }
        for (int i = start; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;
            String sid = getStr(row.getCell(0)).trim();
            String name = getStr(row.getCell(1)).trim();
            // 兼容4列(含性别)和3列(无性别)格式
            String gender, cls;
            if (hasGender) {
                gender = getStr(row.getCell(2)).trim();
                cls = getStr(row.getCell(3)).trim();
            } else {
                cls = getStr(row.getCell(2)).trim();
                gender = "";
            }
            if (!sid.isEmpty() || !name.isEmpty()) list.add(new Student(sid, name, gender, cls));
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
        switch (cell.getCellType()) {
            case STRING: return cell.getStringCellValue();
            case NUMERIC:
                double v = cell.getNumericCellValue();
                return v == Math.floor(v) && !Double.isInfinite(v) ? String.valueOf((long) v) : String.valueOf(v);
            default: return "";
        }
    }
}
