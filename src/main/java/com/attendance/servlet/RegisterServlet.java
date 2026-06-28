package com.attendance.servlet;

import com.attendance.dao.UserDao;
import com.attendance.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDao userDao = new UserDao();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String password2 = req.getParameter("password2");

        if (username == null || username.trim().length() < 2) {
            req.setAttribute("error", "用户名至少2个字符");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }
        if (password == null || password.length() < 3) {
            req.setAttribute("error", "密码至少3位");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(password2)) {
            req.setAttribute("error", "两次密码不一致");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }
        if (userDao.findByUsername(username.trim()) != null) {
            req.setAttribute("error", "用户名已存在");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        boolean ok = userDao.addUser(new User(username.trim(), password));
        if (ok) {
            req.setAttribute("msg", "注册成功，请登录");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        } else {
            req.setAttribute("error", "注册失败，请重试");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }
}
