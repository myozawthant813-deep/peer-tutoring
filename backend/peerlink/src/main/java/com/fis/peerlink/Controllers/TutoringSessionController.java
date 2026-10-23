package com.fis.peerlink.Controllers;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fis.peerlink.Models.TutoringRequest;
import com.fis.peerlink.Models.TutoringSession;
import com.fis.peerlink.Repositories.TutoringSessionRepository;
import com.fis.peerlink.Services.TutoringSessionService;

@RestController
@RequestMapping("/api/tutoring-sessions")
@CrossOrigin(origins = "*")
public class TutoringSessionController {

private final TutoringSessionService sessionService;
private final TutoringSessionRepository sessionRepository;

public TutoringSessionController(
        TutoringSessionService sessionService,
        TutoringSessionRepository sessionRepository) {
    this.sessionService = sessionService;
    this.sessionRepository = sessionRepository;
}

@PostMapping
public ResponseEntity<?> scheduleSession(
        @RequestBody Map<String, Object> body) {

    try {
        Long requestId = Long.valueOf(
                body.get("requestId").toString());

        Long tutorId = Long.valueOf(
                body.get("tutorId").toString());

        LocalDateTime scheduledAt = LocalDateTime.parse(
                body.get("scheduledAt").toString());

        String meetingLink = body.get("meetingLink") == null
                ? ""
                : body.get("meetingLink").toString().trim();

        TutoringSession session = sessionService.scheduleSession(
                requestId,
                tutorId,
                scheduledAt,
                meetingLink);

        return ResponseEntity.status(HttpStatus.CREATED).body(
                Map.of(
                        "id", session.getId(),
                        "requestId", session.getTutoringRequest().getId(),
                        "scheduledAt", session.getScheduledAt().toString(),
                        "meetingLink", session.getMeetingLink(),
                        "status", session.getStatus(),
                        "message", "Tutoring session scheduled successfully."
                )
        );

    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(
                Map.of("error", e.getMessage()));

    } catch (RuntimeException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                Map.of("error", e.getMessage()));
    }
}

@GetMapping("/request/{requestId}")
public ResponseEntity<?> getSessionByRequest(
        @PathVariable Long requestId) {

    return sessionRepository.findByTutoringRequest_Id(requestId)
            .<ResponseEntity<?>>map(session ->
                    ResponseEntity.ok(
                            Map.of(
                                    "id", session.getId(),
                                    "requestId",
                                    session.getTutoringRequest().getId(),
                                    "scheduledAt",
                                    session.getScheduledAt().toString(),
                                    "meetingLink",
                                    session.getMeetingLink() == null
                                            ? ""
                                            : session.getMeetingLink(),
                                    "status", session.getStatus()
                            )
                    )
            )
            .orElseGet(() ->
                    ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                            Map.of("error", "No session found for this request.")
                    )
            );
}
@GetMapping("/tutor/{tutorId}")
public ResponseEntity<?> getTutorSessions(
        @PathVariable Long tutorId) {

    List<TutoringSession> sessions =
            sessionRepository.findByTutoringRequest_Tutor_Id(tutorId);

    List<Map<String, Object>> result = sessions.stream()
            .map(session -> {
                TutoringRequest request =
                        session.getTutoringRequest();

                return Map.<String, Object>of(
                        "id", session.getId(),
                        "requestId", request.getId(),
                        "subject", request.getSubject(),
                        "studentName", request.getRequester().getName(),
                        "scheduledAt", session.getScheduledAt().toString(),
                        "meetingLink",
                        session.getMeetingLink() == null
                                ? "" : session.getMeetingLink(),
                        "status", session.getStatus()
                );
            })
            .toList();

    return ResponseEntity.ok(result);
}

@GetMapping("/student/{studentId}")
public ResponseEntity<?> getStudentSessions(
        @PathVariable Long studentId) {

    List<TutoringSession> sessions =
            sessionRepository.findByTutoringRequest_Requester_Id(studentId);

    List<Map<String, Object>> result = sessions.stream()
            .map(session -> {
                TutoringRequest request =
                        session.getTutoringRequest();

                return Map.<String, Object>of(
                        "id", session.getId(),
                        "requestId", request.getId(),
                        "subject", request.getSubject(),
                        "tutorName", request.getTutor().getName(),
                        "scheduledAt", session.getScheduledAt().toString(),
                        "meetingLink",
                        session.getMeetingLink() == null
                                ? "" : session.getMeetingLink(),
                        "status", session.getStatus()
                );
            })
            .toList();

    return ResponseEntity.ok(result);
}
}