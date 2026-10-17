package com.fis.peerlink.Models;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tutoring_sessions")
public class TutoringSession {

@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;

@OneToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "request_id", nullable = false, unique = true)
private TutoringRequest tutoringRequest;

@Column(name = "scheduled_at", nullable = false)
private LocalDateTime scheduledAt;

@Column(name = "meeting_link", length = 500)
private String meetingLink;

@Column(nullable = false)
private String status = "SCHEDULED";

public TutoringSession() {
}

public Long getId() {
    return id;
}

public TutoringRequest getTutoringRequest() {
    return tutoringRequest;
}

public void setTutoringRequest(TutoringRequest tutoringRequest) {
    this.tutoringRequest = tutoringRequest;
}

public LocalDateTime getScheduledAt() {
    return scheduledAt;
}

public void setScheduledAt(LocalDateTime scheduledAt) {
    this.scheduledAt = scheduledAt;
}

public String getMeetingLink() {
    return meetingLink;
}

public void setMeetingLink(String meetingLink) {
    this.meetingLink = meetingLink;
}

public String getStatus() {
    return status;
}

public void setStatus(String status) {
    this.status = status;
}

}
