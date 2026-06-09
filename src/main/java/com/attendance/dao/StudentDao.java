package com.attendance.dao;

import com.attendance.model.Student;
import com.attendance.util.JDBCUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDao {

    // 获取所有学生，按点名次数升序、答对数降序
    public List<Student> getAllStudents() {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM student ORDER BY total_called ASC, total_correct DESC";
        try (Connection conn = JDBCUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Student s = new Student();
                s.setId(rs.getInt("id"));
                s.setStudentId(rs.getString("student_id"));
                s.setName(rs.getString("name"));
                s.setClassName(rs.getString("class_name"));
                s.setTotalCalled(rs.getInt("total_called"));
                s.setTotalCorrect(rs.getInt("total_correct"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 根据学号查找
    public Student findByStudentId(String studentId) {
        String sql = "SELECT * FROM student WHERE student_id = ?";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Student s = new Student();
                s.setId(rs.getInt("id"));
                s.setStudentId(rs.getString("student_id"));
                s.setName(rs.getString("name"));
                s.setClassName(rs.getString("class_name"));
                s.setTotalCalled(rs.getInt("total_called"));
                s.setTotalCorrect(rs.getInt("total_correct"));
                return s;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 更新点名结果（增加点名次数和答对次数）
    public boolean updateCallResult(String studentId, boolean isCorrect) {
        String sql = "UPDATE student SET total_called = total_called + 1, " +
                "total_correct = total_correct + ? WHERE student_id = ?";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, isCorrect ? 1 : 0);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 添加学生（可用于批量导入扩展）
    public boolean addStudent(Student student) {
        String sql = "INSERT INTO student(student_id, name, class_name) VALUES(?,?,?)";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, student.getStudentId());
            ps.setString(2, student.getName());
            ps.setString(3, student.getClassName());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}