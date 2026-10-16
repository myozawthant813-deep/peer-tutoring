package com.fis.peerlink.Models;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tutoring_requests")
public class TutoringRequest {

@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;

@ManyToOne
@JoinColumn(name = "requester_id", nullable = false)
private User requester;

@ManyToOne
@JoinColumn(name = "tutor_id", nullable = false)
private User tutor;

@Column(nullable = false)
private String subject;

@Column(length = 1000)
private String message;

@Column(nullable = false)
private String status = "PENDING";

@Column(name = "created_at", nullable = false)
private LocalDateTime createAt = LocalDateTime.now();

public TutoringRequest() {
}

public Long getId() {
    return id;
}

public User getRequester() {
    return requester;
}

public void setRequester(User requester) {
    this.requester = requester;
}

public User getTutor() {
    return tutor;
}

public void setTutor(User tutor) {
    this.tutor = tutor;
}

public String getSubject() {
    return subject;
}

public void setSubject(String subject) {
    this.subject = subject;
}

public String getMessage() {
    return message;
}

public void setMessage(String message) {
    this.message = message;
}

public String getStatus() {
    return status;
}

public void setStatus(String status) {
    this.status = status;
}

public LocalDateTime getCreatedAt() {
    return createAt;
}

}
