package com.attendance.service;

import com.attendance.dao.StudentDao;
import com.attendance.dao.RecordDao;
import com.attendance.model.Record;
import com.attendance.model.Student;

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
            // 从答对次数最多的学生中选（已点名过的）
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
            // 如果没有已经点过的，回退到正常点名
        }

        // 正常点名：优先选择被点名次数最少的学生（包括未点过的）
        int minCalled = allStudents.stream().mapToInt(Student::getTotalCalled).min().orElse(0);
        List<Student> candidates = allStudents.stream()
                .filter(s -> s.getTotalCalled() == minCalled)
                .collect(Collectors.toList());
        Random rand = new Random();
        return candidates.get(rand.nextInt(candidates.size()));
    }

    // 记录点名结果（更新学生表 + 插入记录表）
    public boolean recordResult(String studentId, boolean isCorrect) {
        boolean updated = studentDao.updateCallResult(studentId, isCorrect);
        if (updated) {
            Record record = new Record(studentId, new Date(), isCorrect);
            recordDao.addRecord(record);
        }
        return updated;
    }

    public List<Student> getAllStudents() {
        return studentDao.getAllStudents();
    }
}