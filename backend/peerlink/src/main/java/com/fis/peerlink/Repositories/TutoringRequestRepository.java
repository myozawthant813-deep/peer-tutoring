package com.fis.peerlink.Repositories;
import org.springframework.data.jpa.repository.JpaRepository;
import com.fis.peerlink.Models.TutoringRequest;
import java.util.List;

public interface TutoringRequestRepository extends JpaRepository<TutoringRequest, Long> {

    List<TutoringRequest> findByRequester_Id(Long requesterId);

    List<TutoringRequest> findByTutor_Id(Long tutorId);

}
