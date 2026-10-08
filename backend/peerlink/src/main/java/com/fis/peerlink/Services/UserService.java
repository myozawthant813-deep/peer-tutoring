package com.fis.peerlink.Services;

import java.util.List;
import org.springframework.stereotype.Service;

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

    
}
