package com.fis.peerlink.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.fis.peerlink.Models.User;

public interface UserRepository extends JpaRepository<User, Long>{
    
}
