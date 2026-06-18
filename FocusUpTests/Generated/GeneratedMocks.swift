// MARK: - Mocks generated from file: 'FocusUp/Core/Timer/Clock.swift'

import Cuckoo
import Foundation
@testable import FocusUp

class MockClock: Clock, Cuckoo.ProtocolMock, @unchecked Sendable {
    typealias MocksType = any Clock
    typealias Stubbing = __StubbingProxy_Clock
    typealias Verification = __VerificationProxy_Clock

    // Original typealiases

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    private var __defaultImplStub: (any Clock)?

    func enableDefaultImplementation(_ stub: any Clock) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }


    func now() -> Date {
        return cuckoo_manager.call(
            "now() -> Date",
            parameters: (),
            escapingParameters: (),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.now()
        )
    }

    struct __StubbingProxy_Clock: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager
    
        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }
        
        func now() -> Cuckoo.ProtocolStubFunction<(), Date> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockClock.self,
                method: "now() -> Date",
                parameterMatchers: matchers
            ))
        }
    }

    struct __VerificationProxy_Clock: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation
    
        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }
        
        
        @discardableResult
        func now() -> Cuckoo.__DoNotUse<(), Date> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify(
                "now() -> Date",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

class ClockStub:Clock, @unchecked Sendable {


    
    func now() -> Date {
        return DefaultValueRegistry.defaultValue(for: (Date).self)
    }
}


