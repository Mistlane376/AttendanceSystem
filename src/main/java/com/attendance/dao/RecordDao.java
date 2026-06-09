package com.attendance.dao;

import com.attendance.model.Record;
import com.attendance.util.JDBCUtil;

import java.sql.*;
import java.util.Date;

public class RecordDao {

    // 添加点名记录
    public boolean addRecord(Record record) {
        String sql = "INSERT INTO attendance_record(student_id, call_time, is_correct) VALUES(?, ?, ?)";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, record.getStudentId());
            ps.setTimestamp(2, new Timestamp(record.getCallTime().getTime()));
            ps.setInt(3, record.isCorrect() ? 1 : 0);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}