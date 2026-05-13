import Foundation

enum MockResponses {
    static let cameraAssessments: [VIVENResponse] = [
        VIVENResponse(
            threatLevel: .high,
            assess: "Smoke column visible, wind carrying embers eastward. Fire approximately 800m northwest.",
            priority: "Evacuate immediately via southern route. Do not shelter in place.",
            steps: [
                "Grab pre-packed go-bag",
                "Close all windows and doors",
                "Drive south on main road, avoid highway 7",
                "Alert neighbours if safe to do so"
            ],
            watchFor: [
                "Spot fires ahead of main front",
                "Road closures near highway junction",
                "Falling visibility — reduce speed"
            ]
        ),
        VIVENResponse(
            threatLevel: .moderate,
            assess: "Flooding visible in low-lying area. Water level appears to be rising. No immediate structural damage observed.",
            priority: "Move to higher ground now. Avoid walking through moving water.",
            steps: [
                "Move valuables above floor level",
                "Turn off electricity at mains if safe",
                "Move to upper floor or evacuate north",
                "Call emergency services if trapped"
            ],
            watchFor: [
                "Rapid water level rise",
                "Electrical hazards",
                "Unstable ground near water's edge"
            ]
        )
    ]

    static let chatResponses: [String: VIVENResponse] = [
        "wildfire": VIVENResponse(
            threatLevel: .high,
            assess: "Wildfire threat confirmed. Embers and smoke indicate a fast-moving front.",
            priority: "Evacuate now if you are in the path of the fire.",
            steps: [
                "Pack essentials and medication",
                "Close all windows and vents",
                "Leave via the safest route away from smoke",
                "Notify nearby contacts if it is safe"
            ],
            watchFor: [
                "Shifting wind direction",
                "Spot fires and falling embers",
                "Evacuation alerts from local authorities"
            ]
        ),
        "flood": VIVENResponse(
            threatLevel: .moderate,
            assess: "Flood conditions detected. Water intrusion is likely or already underway.",
            priority: "Move to higher ground and avoid entering moving water.",
            steps: [
                "Turn off power if safe to do so",
                "Move valuables above flood level",
                "Avoid basements and underpasses",
                "Check for official evacuation guidance"
            ],
            watchFor: [
                "Rising water levels",
                "Electrical hazards",
                "Structural instability"
            ]
        ),
        "medical": VIVENResponse(
            threatLevel: .high,
            assess: "Medical emergency likely. Immediate support and escalation are recommended.",
            priority: "Call emergency services if the person is unresponsive or struggling to breathe.",
            steps: [
                "Check responsiveness and breathing",
                "Apply first aid if trained",
                "Keep the person still and calm",
                "Prepare to relay location and symptoms to responders"
            ],
            watchFor: [
                "Loss of consciousness",
                "Breathing difficulty",
                "Rapid deterioration"
            ]
        ),
        "default": VIVENResponse(
            threatLevel: .low,
            assess: "Situation assessed. No immediate critical threat detected. Monitoring conditions.",
            priority: "Stay alert and prepared.",
            steps: [
                "Monitor local emergency broadcasts",
                "Keep phone charged",
                "Review your emergency plan"
            ],
            watchFor: [
                "Changing weather conditions",
                "Official evacuation orders"
            ]
        )
    ]

    static func chatResponse(for query: String) -> VIVENResponse {
        let normalized = query.lowercased()
        if normalized.contains("wildfire") || normalized.contains("fire") || normalized.contains("smoke") {
            return chatResponses["wildfire"] ?? chatResponses["default"]!
        }
        if normalized.contains("flood") || normalized.contains("water") || normalized.contains("storm") {
            return chatResponses["flood"] ?? chatResponses["default"]!
        }
        if normalized.contains("medical") || normalized.contains("injury") || normalized.contains("bleeding") || normalized.contains("breathing") {
            return chatResponses["medical"] ?? chatResponses["default"]!
        }
        return chatResponses["default"]!
    }
}
