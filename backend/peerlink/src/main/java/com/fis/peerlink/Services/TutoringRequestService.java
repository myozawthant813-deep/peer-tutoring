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
   public TutoringRequest createRequest(
        Long requesterId,
        Long tutorId,
        String subject,
        String message
) {
    if (requesterId.equals(tutorId)) {
        throw new IllegalArgumentException(
                "You cannot request tutoring from yourself.");
    }

    User requester = userRepository.findById(requesterId)
            .orElseThrow(() ->
                    new RuntimeException("Requester not found."));

    User tutor = userRepository.findById(tutorId)
            .orElseThrow(() ->
                    new RuntimeException("Tutor not found."));

    TutoringRequest request = new TutoringRequest();
    request.setRequester(requester);
    request.setTutor(tutor);
    request.setSubject(subject);
    request.setMessage(message);

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
@Transactional(readOnly = true)
public List<Map<String, Object>> getRequestsByTutor(Long tutorId) {

return requestRepository.findByTutor_Id(tutorId)
        .stream()
        .map(request -> {
            Map<String, Object> result = new LinkedHashMap<>();

            result.put("id", request.getId());
            result.put("requesterId", request.getRequester().getId());
            result.put("requesterName", request.getRequester().getName());
            result.put("subject", request.getSubject());
            result.put("message", request.getMessage());
            result.put("status", request.getStatus());
            result.put("createdAt", request.getCreatedAt());

            return result;
        })
        .collect(Collectors.toList());

}


@Transactional
public TutoringRequest updateRequestStatus(
Long requestId,
Long tutorId,
String status) {

if (requestId == null || tutorId == null || status == null) {
    throw new IllegalArgumentException(
            "Request ID, tutor ID, and status are required.");
}

if (!"ACCEPTED".equals(status) && !"REJECTED".equals(status)) {
    throw new IllegalArgumentException(
            "Status must be ACCEPTED or REJECTED.");
}

TutoringRequest request = requestRepository.findById(requestId)
        .orElseThrow(() ->
                new RuntimeException("Tutoring request not found."));

if (request.getTutor() == null
        || !tutorId.equals(request.getTutor().getId())) {
    throw new IllegalArgumentException(
            "You cannot update another tutor's request.");
}

if (!"PENDING".equals(request.getStatus())) {
    throw new IllegalArgumentException(
            "This request has already been processed.");
}

request.setStatus(status);

return requestRepository.save(request);

}



}
