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
    public int countAll() { return studentDao.countAll(); }

    public Map<String, Object> batchImport(List<Student> students) {
        Map<String, Object> result = new HashMap<>();
        int success = 0, fail = 0;
        Connection conn = null;
        try {
            conn = JDBCUtil.getConnection();
            conn.setAutoCommit(false);
            for (Student s : students) {
                if (s.getStudentId() == null || s.getStudentId().trim().isEmpty()
                        || s.getName() == null || s.getName().trim().isEmpty()) {
                    fail++; continue;
                }
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
        return result;
    }

    public List<Student> parseExcel(InputStream is, String fileName) throws IOException {
        List<Student> list = new ArrayList<>();
        Workbook wb = fileName.endsWith(".xlsx") ? new XSSFWorkbook(is) : new HSSFWorkbook(is);
        Sheet sheet = wb.getSheetAt(0);
        int start = 0;
        Row hdr = sheet.getRow(0);
        if (hdr != null && hdr.getCell(0) != null) {
            String v = getStr(hdr.getCell(0));
            if ("学号".equals(v) || "姓名".equals(v) || "name".equalsIgnoreCase(v)) start = 1;
        }
        for (int i = start; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;
            String sid = getStr(row.getCell(0)).trim();
            String name = getStr(row.getCell(1)).trim();
            String cls = getStr(row.getCell(2)).trim();
            if (!sid.isEmpty() || !name.isEmpty()) list.add(new Student(sid, name, cls));
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
        if (p.length >= 2 && !p[0].trim().isEmpty()) list.add(new Student(p[0].trim(), p[1].trim(), p.length >= 3 ? p[2].trim() : ""));
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
