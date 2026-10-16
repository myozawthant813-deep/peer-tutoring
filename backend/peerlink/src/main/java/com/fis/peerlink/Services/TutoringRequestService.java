package com.fis.peerlink.Services;

import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.stream.Collectors;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.stereotype.Service;

import com.fis.peerlink.Models.TutoringRequest;
import com.fis.peerlink.Models.User;
import com.fis.peerlink.Repositories.TutoringRequestRepository;
import com.fis.peerlink.Repositories.UserRepository;
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

    @Transactional(readOnly = true)
public List<Map<String, Object>> getRequestsByRequester(
        Long requesterId) {

    return requestRepository
            .findByRequester_Id(requesterId)
            .stream()
            .map(request -> {
                Map<String, Object> result = new LinkedHashMap<>();

                result.put("id", request.getId());
                result.put("tutorId", request.getTutor().getId());
                result.put("tutorName", request.getTutor().getName());
                result.put("subject", request.getSubject());
                result.put("message", request.getMessage());
                result.put("status", request.getStatus());
                result.put("createdAt", request.getCreatedAt());

                return result;
            })
            .collect(Collectors.toList());
}
}
