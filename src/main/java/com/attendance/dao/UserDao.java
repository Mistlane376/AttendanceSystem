package com.attendance.dao;

import com.attendance.model.User;
import com.attendance.util.JDBCUtil;

import java.sql.*;

public class UserDao {

    public User findByUsername(String username) {
        String sql = "SELECT * FROM sys_user WHERE username = ?";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setPassword(rs.getString("password"));
                u.setRole(rs.getString("role"));
                return u;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean addUser(User user) {
        String sql = "INSERT INTO sys_user (username, password, role) VALUES (?, ?, ?)";
        try (Connection conn = JDBCUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getRole() != null ? user.getRole() : "teacher");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public int countAll() {
        try (Connection conn = JDBCUtil.getConnection(); Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM sys_user")) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { return 0; }
    }
}
