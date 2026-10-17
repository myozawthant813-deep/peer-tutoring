package com.fis.peerlink.Repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fis.peerlink.Models.TutoringSession;

public interface TutoringSessionRepository
extends JpaRepository<TutoringSession, Long> {

Optional<TutoringSession> findByTutoringRequest_Id(Long requestId);

}
