package com.fis.peerlink.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fis.peerlink.Models.TutoringSession;

public interface TutoringSessionRepository
        extends JpaRepository<TutoringSession, Long> {

    Optional<TutoringSession> findByTutoringRequest_Id(Long requestId);


    List<TutoringSession> findByTutoringRequest_Requester_Id(Long studentId);

List<TutoringSession> findByTutoringRequest_Tutor_Id(Long tutorId);
}
