package com.fis.peerlink.Services;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.fis.peerlink.Models.User;
import com.fis.peerlink.Repositories.UserRepository;

@Service 
public class UserService {
    private final UserRepository userRepository;

    public UserService (UserRepository userRepository){
        this.userRepository = userRepository;
    }
    
    public User creteUser(User user){
        return userRepository.save(user);
    }

    public List<User> getAllUsers () {
        return userRepository.findAll();
    }

    public User login(String email, String password){
        User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("No such user found!"));
        if (!user.getPassword().equals(password)){
            throw new RuntimeException("Incorrect password");
        };

    return user;
    }

public User updateProfile(
        Long userId,
        Map<String, Object> request) {

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found"));

    if (request.containsKey("name")) {
        String name = String.valueOf(request.get("name")).trim();

        if (name.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Name cannot be empty");
        }

        user.setName(name);
    }

    if (request.containsKey("university")) {
        user.setUniversity(
                String.valueOf(request.get("university")).trim());
    }

    if (request.containsKey("major")) {
        user.setMajor(
                String.valueOf(request.get("major")).trim());
    }

    if (request.containsKey("year")) {
        try {
            user.setYear(
                    Integer.parseInt(
                            String.valueOf(request.get("year"))));
        } catch (NumberFormatException e) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Year must be a valid number");
        }
    }

    if (request.containsKey("bio")) {
        user.setBio(
                String.valueOf(request.get("bio")).trim());
    }

    if (request.containsKey("profileImage")) {
        user.setProfileImage(
                String.valueOf(request.get("profileImage")).trim());
    }

    return userRepository.save(user);
}

public User getUserById(Long id) {
    return userRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found with id: " + id));
}


    
}
