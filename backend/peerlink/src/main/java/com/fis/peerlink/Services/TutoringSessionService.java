package com.fis.peerlink.Services;

import java.time.LocalDateTime;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fis.peerlink.Models.TutoringRequest;
import com.fis.peerlink.Models.TutoringSession;
import com.fis.peerlink.Repositories.TutoringRequestRepository;
import com.fis.peerlink.Repositories.TutoringSessionRepository;

@Service
public class TutoringSessionService {

private final TutoringSessionRepository sessionRepository;
private final TutoringRequestRepository requestRepository;

public TutoringSessionService(
        TutoringSessionRepository sessionRepository,
        TutoringRequestRepository requestRepository) {
    this.sessionRepository = sessionRepository;
    this.requestRepository = requestRepository;
}

@Transactional
public TutoringSession scheduleSession(
        Long requestId,
        Long tutorId,
        LocalDateTime scheduledAt,
        String meetingLink) {

    if (requestId == null || tutorId == null || scheduledAt == null) {
        throw new IllegalArgumentException(
                "Request ID, tutor ID, and session time are required.");
    }

    if (!scheduledAt.isAfter(LocalDateTime.now())) {
        throw new IllegalArgumentException(
                "The session must be scheduled for a future time.");
    }

    TutoringRequest request = requestRepository.findById(requestId)
            .orElseThrow(() ->
                    new RuntimeException("Tutoring request not found."));

    if (request.getTutor() == null
            || !tutorId.equals(request.getTutor().getId())) {
        throw new IllegalArgumentException(
                "Only the assigned tutor can schedule this session.");
    }

    if (!"ACCEPTED".equals(request.getStatus())) {
        throw new IllegalArgumentException(
                "Only accepted tutoring requests can be scheduled.");
    }

    if (sessionRepository.findByTutoringRequest_Id(requestId).isPresent()) {
        throw new IllegalArgumentException(
                "A session already exists for this request.");
    }

    TutoringSession session = new TutoringSession();
    session.setTutoringRequest(request);
    session.setScheduledAt(scheduledAt);
    session.setMeetingLink(meetingLink);
    session.setStatus("SCHEDULED");

    return sessionRepository.save(session);
}


}
