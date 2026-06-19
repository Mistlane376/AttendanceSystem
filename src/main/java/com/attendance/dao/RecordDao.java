package com.attendance.dao;

import com.attendance.model.Record;
import com.attendance.util.JDBCUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class RecordDao {

    // 插入一条点名记录
    public boolean addRecord(Record record) {
        try (Connection conn = JDBCUtil.getConnection()) {
            return addRecord(conn, record);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 使用外部传入的连接（支持事务）
    public boolean addRecord(Connection conn, Record record) throws SQLException {
        String sql = "INSERT INTO attendance_record (student_id, call_time, is_correct) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, record.getStudentId());
            ps.setTimestamp(2, new java.sql.Timestamp(record.getCallTime().getTime()));
            ps.setBoolean(3, record.isCorrect());
            return ps.executeUpdate() > 0;
        }
    }
}