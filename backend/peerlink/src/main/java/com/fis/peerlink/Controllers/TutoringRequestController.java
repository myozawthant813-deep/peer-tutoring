package com.fis.peerlink.Controllers;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fis.peerlink.Models.TutoringRequest;
import com.fis.peerlink.Services.TutoringRequestService;

@RestController 
@RequestMapping ("/api/tutoring-requests")
@CrossOrigin (origins = "*")
public class TutoringRequestController {
    private final TutoringRequestService requestService;

    public TutoringRequestController(TutoringRequestService requestService){
        this.requestService = requestService;
    }

    @PostMapping 
    public ResponseEntity<?> creataeRequest(@RequestBody Map<String, Object> body){
        try{
            Long requesterId = Long.valueOf(body.get("requesterId").toString());

            Long tutorId = Long.valueOf(body.get("tutorId").toString());

            String subject = body.get("subject").toString().trim();

            String message = body.get("message") == null ? "" : body.get("message").toString().trim();

            if (subject.isEmpty()){
                return ResponseEntity.badRequest().body(Map.of("error: ", "Subject is required."));
            }

            TutoringRequest request = requestService.createRequest(requesterId, tutorId, subject, message);

            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "id", request.getId(),
                "subject", request.getSubject(),
                "status", request.getStatus(),
                "message", "Tutoring request created."
            ));

        }catch (IllegalArgumentException e){
                return ResponseEntity.badRequest().body(Map.of("error: ", e.getMessage()));
        }catch (RuntimeException e){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error: ", e.getMessage()));

        }
    }
    @GetMapping("/requester/{requesterId}")
public ResponseEntity<List<Map<String, Object>>> getMyRequests(
        @PathVariable Long requesterId) {

    List<Map<String, Object>> requests =
            requestService.getRequestsByRequester(requesterId);

    return ResponseEntity.ok(requests);
}
@GetMapping("/tutor/{tutorId}")
public ResponseEntity<List<Map<String, Object>>> getIncomingRequests(
@PathVariable Long tutorId) {

List<Map<String, Object>> requests =
        requestService.getRequestsByTutor(tutorId);

return ResponseEntity.ok(requests);

}

@PatchMapping("/{requestId}/status")
public ResponseEntity<?> updateRequestStatus(
@PathVariable Long requestId,
@RequestBody Map<String, Object> body) {

try {
    Long tutorId = Long.valueOf(body.get("tutorId").toString());
    String status = body.get("status").toString().trim().toUpperCase();

    TutoringRequest request = requestService.updateRequestStatus(
            requestId, tutorId, status);

    return ResponseEntity.ok(Map.of(
            "id", request.getId(),
            "status", request.getStatus(),
            "message", "Request status updated successfully."
    ));

} catch (IllegalArgumentException e) {
    return ResponseEntity.badRequest().body(
            Map.of("error", e.getMessage()));

} catch (RuntimeException e) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
            Map.of("error", e.getMessage()));
}

}

}
