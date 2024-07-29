

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserAccountManager {
    
    struct UserAccount {
        address userAddress;
        string username;
        string publicKey;
        uint256 otpSeed;
        uint256 lastOtp;
        uint256 lastOtpTimestamp;
    }

    address public owner;
    mapping(address => UserAccount) private userAccounts;
    mapping(string => bool) private registeredUsernames;
    mapping(address => bool) private registeredUsers;

    event UserRegistered(address indexed userAddress, string username, string publicKey);
    event OTPGenerated(address indexed userAddress, uint256 otp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRegisteredUser(address _userAddress) {
        require(registeredUsers[_userAddress], "User not registered");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser(address _userAddress, string memory _username, string memory _publicKey, uint256 _otpSeed) external onlyOwner {
        require(!registeredUsers[_userAddress], "User already registered");
        require(!registeredUsernames[_username], "Username already taken");

        userAccounts[_userAddress] = UserAccount({
            userAddress: _userAddress,
            username: _username,
            publicKey: _publicKey,
            otpSeed: _otpSeed,
            lastOtp: 0,
            lastOtpTimestamp: 0
        });

        registeredUsers[_userAddress] = true;
        registeredUsernames[_username] = true;
        emit UserRegistered(_userAddress, _username, _publicKey);
    }

    function generateOTP(address _userAddress) external onlyRegisteredUser(_userAddress) {
        uint256 currentTime = block.timestamp;
        require(currentTime - userAccounts[_userAddress].lastOtpTimestamp > 60, "OTP can only be generated once per minute");

        uint256 otp = uint256(keccak256(abi.encodePacked(userAccounts[_userAddress].otpSeed, currentTime))) % 1000000;
        userAccounts[_userAddress].lastOtp = otp;
        userAccounts[_userAddress].lastOtpTimestamp = currentTime;

        emit OTPGenerated(_userAddress, otp);
    }

    function authenticateUser(address _userAddress, uint256 _otp) external view onlyRegisteredUser(_userAddress) returns (bool) {
        uint256 currentTime = block.timestamp;
        require(currentTime - userAccounts[_userAddress].lastOtpTimestamp <= 300, "OTP has expired");
        require(_otp == userAccounts[_userAddress].lastOtp, "Invalid OTP");

        return true;
    }

    function getUserPublicKey(address _userAddress) external view onlyRegisteredUser(_userAddress) returns (string memory) {
        return userAccounts[_userAddress].publicKey;
    }

    function getUserOTP(address _userAddress) external view onlyRegisteredUser(_userAddress) returns (uint256) {
        return userAccounts[_userAddress].lastOtp;
    }
}
