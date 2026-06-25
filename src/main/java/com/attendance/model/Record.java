package com.attendance.model;

import java.util.Date;

public class Record {
    private int id;
    private String studentId;
    private Date callTime;
    private boolean isCorrect;

    public Record() {}

    public Record(String studentId, Date callTime, boolean isCorrect) {
        this.studentId = studentId;
        this.callTime = callTime;
        this.isCorrect = isCorrect;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public Date getCallTime() { return callTime; }
    public void setCallTime(Date callTime) { this.callTime = callTime; }
    public boolean isCorrect() { return isCorrect; }
    public void setCorrect(boolean correct) { isCorrect = correct; }
}
