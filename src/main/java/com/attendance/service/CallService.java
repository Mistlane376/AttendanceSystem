package com.attendance.service;

import com.attendance.dao.StudentDao;
import com.attendance.dao.RecordDao;
import com.attendance.model.Record;
import com.attendance.model.Student;
import com.attendance.util.JDBCUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

public class CallService {
    private StudentDao studentDao = new StudentDao();
    private RecordDao recordDao = new RecordDao();

    public Student selectStudent(boolean needHighScore) {
        List<Student> all = studentDao.getAllStudents();
        if (all.isEmpty()) return null;

        if (needHighScore) {
            List<Student> high = all.stream().filter(s -> s.getTotalCalled() > 0).collect(Collectors.toList());
            if (!high.isEmpty()) {
                int max = high.stream().mapToInt(Student::getTotalCorrect).max().orElse(0);
                List<Student> c = high.stream().filter(s -> s.getTotalCorrect() == max).collect(Collectors.toList());
                return c.get(new Random().nextInt(c.size()));
            }
        }
        int min = all.stream().mapToInt(Student::getTotalCalled).min().orElse(0);
        List<Student> c = all.stream().filter(s -> s.getTotalCalled() == min).collect(Collectors.toList());
        return c.get(new Random().nextInt(c.size()));
    }

    public boolean recordResult(String studentId, boolean isCorrect) {
        Connection conn = null;
        try {
            conn = JDBCUtil.getConnection();
            conn.setAutoCommit(false);
            if (!studentDao.updateCallResult(conn, studentId, isCorrect)) { conn.rollback(); return false; }
            if (!recordDao.addRecord(conn, new Record(studentId, new Date(), isCorrect))) { conn.rollback(); return false; }
            conn.commit(); return true;
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) {} }
            return false;
        } finally {
            if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException e) {} JDBCUtil.close(conn, null, null); }
        }
    }

    public List<Student> getAllStudents() { return studentDao.getAllStudents(); }
}
