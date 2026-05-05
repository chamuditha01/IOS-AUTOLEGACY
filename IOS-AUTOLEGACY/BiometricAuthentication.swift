import LocalAuthentication
import Foundation

class BiometricAuthentication {
    static let shared = BiometricAuthentication()
    
    private init() {}
    
    enum BiometricType {
        case faceID
        case touchID
        case none
    }
    
    enum AuthenticationError: LocalizedError {
        case invalidContext
        case cancelledByUser
        case failedAuthentication
        case biometricNotAvailable
        case biometricNotEnrolled
        case passcodeNotSet
        case unknownError(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidContext:
                return "Unable to create authentication context"
            case .cancelledByUser:
                return "Authentication was cancelled"
            case .failedAuthentication:
                return "Biometric authentication failed. Please try again."
            case .biometricNotAvailable:
                return "Biometric authentication is not available on this device"
            case .biometricNotEnrolled:
                return "No biometric data enrolled on this device"
            case .passcodeNotSet:
                return "Device passcode is not set"
            case .unknownError(let error):
                return error.localizedDescription
            }
        }
    }
    
    func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        if #available(iOS 11, *) {
            return context.biometryType == .faceID ? .faceID : .touchID
        }
        return .touchID
    }
    
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            print("📱 Biometric availability check - Error: \(error.localizedDescription), Code: \(error.code)")
        } else {
            print("📱 Biometric available: \(available), Type: \(context.biometryType)")
        }
        
        return available
    }
    
    func authenticate(reason: String = "Authenticate to unlock AutoLegacy") async throws {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw AuthenticationError.unknownError(error)
            }
            throw AuthenticationError.biometricNotAvailable
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if !success {
                throw AuthenticationError.failedAuthentication
            }
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel:
                throw AuthenticationError.cancelledByUser
            case .biometryNotAvailable:
                throw AuthenticationError.biometricNotAvailable
            case .biometryNotEnrolled:
                throw AuthenticationError.biometricNotEnrolled
            case .biometryLockout:
                throw AuthenticationError.failedAuthentication
            default:
                throw AuthenticationError.unknownError(error)
            }
        } catch {
            throw AuthenticationError.unknownError(error)
        }
    }
}
