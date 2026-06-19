package com.attendance.dao;

import com.attendance.model.Record;
import com.attendance.util.JDBCUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

    // 获取最近的记录（用于展示历史）
    public List<Record> getRecentRecords(int limit) {
        List<Record> list = new ArrayList<>();
        String sql = "SELECT * FROM attendance_record ORDER BY call_time DESC LIMIT ?";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Record r = new Record();
                r.setId(rs.getInt("id"));
                r.setStudentId(rs.getString("student_id"));
                r.setCallTime(rs.getTimestamp("call_time"));
                r.setCorrect(rs.getBoolean("is_correct"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 总记录数
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM attendance_record";
        try (Connection conn = JDBCUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 总答对数
    public int countCorrect() {
        String sql = "SELECT COUNT(*) FROM attendance_record WHERE is_correct = 1";
        try (Connection conn = JDBCUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}