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

    public List<Student> getAllStudents() {
        return studentDao.getAllStudents();
    }

    public Student findByStudentId(String studentId) {
        return studentDao.findByStudentId(studentId);
    }

    public boolean addStudent(Student student) {
        return studentDao.addStudent(student);
    }

    public int countAll() { return studentDao.countAll(); }

    public int totalCalled() { return studentDao.totalCalled(); }

    public List<String[]> classDistribution() { return studentDao.classDistribution(); }

    // 批量导入学生（事务保护）
    public Map<String, Object> batchImport(List<Student> students) {
        Map<String, Object> result = new HashMap<>();
        int success = 0, fail = 0;
        List<String> errors = new ArrayList<>();

        Connection conn = null;
        try {
            conn = JDBCUtil.getConnection();
            conn.setAutoCommit(false);

            for (Student s : students) {
                if (s.getStudentId() == null || s.getStudentId().trim().isEmpty()
                        || s.getName() == null || s.getName().trim().isEmpty()) {
                    fail++;
                    errors.add("跳过空数据行");
                    continue;
                }
                try {
                    studentDao.addStudent(conn, s);
                    success++;
                } catch (SQLException e) {
                    fail++;
                    errors.add(s.getStudentId() + " " + s.getName() + ": " + e.getMessage());
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            result.put("error", "数据库异常: " + e.getMessage());
            return result;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); }
                JDBCUtil.close(conn, null, null);
            }
        }

        result.put("success", success);
        result.put("fail", fail);
        result.put("errors", errors);
        return result;
    }

    // 解析 Excel 文件（支持 .xlsx 和 .xls）
    public List<Student> parseExcel(InputStream inputStream, String fileName) throws IOException {
        List<Student> students = new ArrayList<>();
        Workbook workbook;

        if (fileName.endsWith(".xlsx")) {
            workbook = new XSSFWorkbook(inputStream);
        } else if (fileName.endsWith(".xls")) {
            workbook = new HSSFWorkbook(inputStream);
        } else {
            throw new IllegalArgumentException("不支持的文件格式，请使用 .xlsx 或 .xls");
        }

        Sheet sheet = workbook.getSheetAt(0);
        int firstRow = 0;

        // 检测第一行是否为表头（第一列为"学号"或"姓名"时跳过）
        Row headerRow = sheet.getRow(0);
        if (headerRow != null) {
            Cell firstCell = headerRow.getCell(0);
            if (firstCell != null) {
                String val = getCellString(firstCell);
                if ("学号".equals(val) || "姓名".equals(val) || "student_id".equalsIgnoreCase(val)
                        || "name".equalsIgnoreCase(val) || "学号/工号".equals(val)) {
                    firstRow = 1;
                }
            }
        }

        for (int i = firstRow; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;

            String studentId = getCellString(row.getCell(0)).trim();
            String name = getCellString(row.getCell(1)).trim();
            String className = row.getCell(2) != null ? getCellString(row.getCell(2)).trim() : "";

            if (studentId.isEmpty() && name.isEmpty()) continue;

            students.add(new Student(studentId, name, className));
        }

        workbook.close();
        return students;
    }

    // 解析文本文件（CSV / TSV）
    public List<Student> parseText(InputStream inputStream) throws IOException {
        List<Student> students = new ArrayList<>();
        BufferedReader reader = null;

        // 尝试 UTF-8
        try {
            reader = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));
            String firstLine = reader.readLine();
            if (firstLine != null && isHeaderLine(firstLine)) {
                // 跳过表头
            } else if (firstLine != null) {
                parseLine(firstLine, students);
            }
        } catch (Exception e) {
            // 编码问题，忽略
        }

        // 如果 UTF-8 失败则无法继续
        if (reader == null) {
            return students;
        }

        String line;
        while ((line = reader.readLine()) != null) {
            parseLine(line, students);
        }
        reader.close();
        return students;
    }

    private boolean isHeaderLine(String line) {
        String lower = line.toLowerCase().trim();
        return lower.startsWith("学号") || lower.startsWith("姓名")
                || lower.startsWith("student") || lower.startsWith("name");
    }

    private void parseLine(String line, List<Student> students) {
        line = line.trim();
        if (line.isEmpty()) return;

        // 自动检测分隔符：逗号、制表符、分号
        String sep = ",";
        if (!line.contains(",") && line.contains("\t")) sep = "\t";
        else if (!line.contains(",") && !line.contains("\t") && line.contains(";")) sep = ";";

        String[] parts = line.split(sep, -1);
        if (parts.length < 2) return;

        String studentId = parts[0].trim();
        String name = parts[1].trim();
        String className = parts.length >= 3 ? parts[2].trim() : "";

        if (!studentId.isEmpty() && !name.isEmpty()) {
            students.add(new Student(studentId, name, className));
        }
    }

    // 获取 Excel 单元格字符串值
    private static String getCellString(Cell cell) {
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                double val = cell.getNumericCellValue();
                if (val == Math.floor(val) && !Double.isInfinite(val)) {
                    return String.valueOf((long) val);
                }
                return String.valueOf(val);
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                try {
                    return cell.getStringCellValue();
                } catch (Exception e) {
                    return String.valueOf(cell.getNumericCellValue());
                }
            default:
                return "";
        }
    }
}