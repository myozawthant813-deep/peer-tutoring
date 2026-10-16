package com.fis.peerlink.Services;

import org.springframework.stereotype.Service;

import com.fis.peerlink.Models.TutoringRequest;
import com.fis.peerlink.Models.User;
import com.fis.peerlink.Repositories.TutoringRequestRepository;
import com.fis.peerlink.Repositories.UserRepository;

import jakarta.transaction.Transactional;
@Service 
public class TutoringRequestService {

    private final TutoringRequestRepository requestRepository;
    private final UserRepository userRepository;


    public TutoringRequestService(TutoringRequestRepository requestRepository, UserRepository userRepository){
        this.requestRepository = requestRepository;
        this.userRepository = userRepository;
    }
    @Transactional 
    public TutoringRequest createRequest(
        Long requesterId,
        Long tutorId,
        String subject,
        String Message
    ){
    if (requesterId.equals(tutorId)){
        throw new IllegalArgumentException("You can't tutoring for yourself");
    }  
    User requester = userRepository.findById(requesterId).orElseThrow(() -> new RuntimeException("Requester not found"));
    User tutor = userRepository.findById(tutorId).orElseThrow(() -> new RuntimeException("Tutor Not found"));

    TutoringRequest request = new TutoringRequest();
    request.setRequester(requester);
    request.setTutor(tutor);
    request.setSubject(subject);
    request.setMessage(Message);


    return requestRepository.save(request);
    
    }
}
