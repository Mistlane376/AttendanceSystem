package com.attendance.service;

import com.attendance.dao.StudentDao;
import com.attendance.dao.RecordDao;
import com.attendance.model.Record;
import com.attendance.model.Student;
import com.attendance.util.JDBCUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

public class CallService {
    private StudentDao studentDao = new StudentDao();
    private RecordDao recordDao = new RecordDao();

    /**
     * 点名算法：确保机会均等
     * @param needHighScore 是否从高分学生中选（连续答错时触发）
     * @return 选中的学生
     */
    public Student selectStudent(boolean needHighScore) {
        List<Student> allStudents = studentDao.getAllStudents();
        if (allStudents.isEmpty()) return null;

        if (needHighScore) {
            List<Student> highScore = allStudents.stream()
                    .filter(s -> s.getTotalCalled() > 0)
                    .collect(Collectors.toList());
            if (!highScore.isEmpty()) {
                int maxCorrect = highScore.stream().mapToInt(Student::getTotalCorrect).max().orElse(0);
                List<Student> candidates = highScore.stream()
                        .filter(s -> s.getTotalCorrect() == maxCorrect)
                        .collect(Collectors.toList());
                Random rand = new Random();
                return candidates.get(rand.nextInt(candidates.size()));
            }
        }

        int minCalled = allStudents.stream().mapToInt(Student::getTotalCalled).min().orElse(0);
        List<Student> candidates = allStudents.stream()
                .filter(s -> s.getTotalCalled() == minCalled)
                .collect(Collectors.toList());
        Random rand = new Random();
        return candidates.get(rand.nextInt(candidates.size()));
    }

    // 记录点名结果（更新学生表 + 插入记录表，同一事务）
    public boolean recordResult(String studentId, boolean isCorrect) {
        Connection conn = null;
        try {
            conn = JDBCUtil.getConnection();
            conn.setAutoCommit(false);

            boolean updated = studentDao.updateCallResult(conn, studentId, isCorrect);
            if (!updated) {
                conn.rollback();
                return false;
            }

            Record record = new Record(studentId, new Date(), isCorrect);
            boolean inserted = recordDao.addRecord(conn, record);
            if (!inserted) {
                conn.rollback();
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); }
                JDBCUtil.close(conn, null, null);
            }
        }
    }

    public List<Student> getAllStudents() {
        return studentDao.getAllStudents();
    }
}