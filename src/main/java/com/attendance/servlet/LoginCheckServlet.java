package com.attendance.servlet;

import com.attendance.dao.UserDao;
import com.attendance.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/loginCheck")
public class LoginCheckServlet extends HttpServlet {
    private UserDao userDao = new UserDao();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null) {
            req.setAttribute("errorMsg", "请输入用户名和密码");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        // 先查数据库
        User user = userDao.findByUsername(username);
        if (user != null && user.getPassword().equals(password)) {
            HttpSession session = req.getSession();
            session.setAttribute("user", username);
            session.setAttribute("role", user.getRole());
            resp.sendRedirect("call.jsp");
            return;
        }

        // 如果数据库无此用户，回退到默认管理员（仅当未注册过时）
        if ("admin".equals(username) && "123".equals(password) && userDao.countAll() == 0) {
            // 自动创建管理员账号
            userDao.addUser(new User("admin", "123"));
            HttpSession session = req.getSession();
            session.setAttribute("user", username);
            session.setAttribute("role", "admin");
            resp.sendRedirect("call.jsp");
            return;
        }

        req.setAttribute("errorMsg", "用户名或密码错误");
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect("login.jsp");
    }
}
