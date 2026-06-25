package com.attendance.dao;

import com.attendance.model.Student;
import com.attendance.util.JDBCUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDao {

    public List<Student> getAllStudents() {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM student ORDER BY total_called ASC, total_correct DESC";
        try (Connection conn = JDBCUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Student findByStudentId(String studentId) {
        String sql = "SELECT * FROM student WHERE student_id = ?";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean addStudent(Student s) {
        String sql = "INSERT INTO student(student_id, name, class_name) VALUES(?,?,?)";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getStudentId());
            ps.setString(2, s.getName());
            ps.setString(3, s.getClassName());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean addStudent(Connection conn, Student s) throws SQLException {
        String sql = "INSERT INTO student(student_id, name, class_name) VALUES(?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getStudentId());
            ps.setString(2, s.getName());
            ps.setString(3, s.getClassName());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStudent(Student s) {
        String sql = "UPDATE student SET name=?, class_name=? WHERE student_id=?";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getName());
            ps.setString(2, s.getClassName());
            ps.setString(3, s.getStudentId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteStudent(String studentId) {
        Connection conn = null;
        try {
            conn = JDBCUtil.getConnection();
            conn.setAutoCommit(false);
            try (Statement stmt = conn.createStatement()) { stmt.execute("SET FOREIGN_KEY_CHECKS = 0"); }
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM attendance_record WHERE student_id = ?")) {
                ps.setString(1, studentId); ps.executeUpdate();
            } catch (SQLException ignored) {}
            boolean ok;
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM student WHERE student_id = ?")) {
                ps.setString(1, studentId);
                ok = ps.executeUpdate() > 0;
            }
            try (Statement stmt = conn.createStatement()) { stmt.execute("SET FOREIGN_KEY_CHECKS = 1"); }
            conn.commit();
            return ok;
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) {} }
            e.printStackTrace(); return false;
        } finally {
            if (conn != null) {
                try (Statement stmt = conn.createStatement()) { stmt.execute("SET FOREIGN_KEY_CHECKS = 1"); } catch (SQLException ignored) {}
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
                JDBCUtil.close(conn, null, null);
            }
        }
    }

    public boolean updateCallResult(Connection conn, String studentId, boolean isCorrect) throws SQLException {
        String sql = "UPDATE student SET total_called = total_called + 1, total_correct = total_correct + ? WHERE student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, isCorrect ? 1 : 0);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        }
    }

    public int countAll() {
        try (Connection conn = JDBCUtil.getConnection(); Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM student")) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { return 0; }
    }

    private Student mapRow(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setId(rs.getInt("id"));
        s.setStudentId(rs.getString("student_id"));
        s.setName(rs.getString("name"));
        s.setClassName(rs.getString("class_name"));
        s.setTotalCalled(rs.getInt("total_called"));
        s.setTotalCorrect(rs.getInt("total_correct"));
        return s;
    }
}
