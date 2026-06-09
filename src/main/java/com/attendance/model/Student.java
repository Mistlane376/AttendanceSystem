package com.attendance.model;

public class Student {
    private int id;
    private String studentId;
    private String name;
    private String className;
    private int totalCalled;
    private int totalCorrect;

    public Student() {}

    public Student(String studentId, String name, String className) {
        this.studentId = studentId;
        this.name = name;
        this.className = className;
        this.totalCalled = 0;
        this.totalCorrect = 0;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
    public int getTotalCalled() { return totalCalled; }
    public void setTotalCalled(int totalCalled) { this.totalCalled = totalCalled; }
    public int getTotalCorrect() { return totalCorrect; }
    public void setTotalCorrect(int totalCorrect) { this.totalCorrect = totalCorrect; }

    public double getCorrectRate() {
        if (totalCalled == 0) return 0;
        return (double) totalCorrect / totalCalled * 100;
    }
}