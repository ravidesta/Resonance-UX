// ChartCalculator.swift
// Luminous Cosmic Architecture™
// Birth Chart Calculation Engine

import Foundation
import SwiftUI

// MARK: - Chart Calculator

class ChartCalculator: ObservableObject {
    @Published var natalChart: NatalChart?
    @Published var currentTransits: [Transit] = []
    @Published var currentMoonPhase: MoonPhase = .newMoon

    // MARK: - Calculate Natal Chart

    func calculateChart(birthDate: Date, birthPlace: String, latitude: Double, longitude: Double) -> NatalChart {
        let planets = calculatePlanetaryPositions(date: birthDate, latitude: latitude, longitude: longitude)
        let houses = calculateHouses(date: birthDate, latitude: latitude, longitude: longitude)
        let aspects = calculateAspects(planets: planets)

        let chart = NatalChart(
            birthDate: birthDate,
            birthPlace: birthPlace,
            latitude: latitude,
            longitude: longitude,
            planets: planets,
            houses: houses,
            aspects: aspects
        )

        DispatchQueue.main.async {
            self.natalChart = chart
        }

        return chart
    }

    // MARK: - Planetary Positions

    /// Calculates approximate planetary positions using simplified orbital mechanics.
    /// For a production app, this would integrate with Swiss Ephemeris or a similar library.
    func calculatePlanetaryPositions(date: Date, latitude: Double, longitude: Double) -> [PlanetaryPosition] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        // Julian Day Number calculation
        let jd = julianDay(from: date)

        // Centuries from J2000.0
        let T = (jd - 2451545.0) / 36525.0

        var positions: [PlanetaryPosition] = []

        // Sun position (using simplified formula)
        let sunLong = normalizeAngle(sunLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .sun, longitude: sunLong))

        // Moon position (simplified)
        let moonLong = normalizeAngle(moonLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .moon, longitude: moonLong))

        // Mercury
        let mercuryLong = normalizeAngle(mercuryLongitude(T: T))
        let mercuryRetro = isMercuryRetrograde(T: T)
        positions.append(PlanetaryPosition(planet: .mercury, longitude: mercuryLong, isRetrograde: mercuryRetro))

        // Venus
        let venusLong = normalizeAngle(venusLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .venus, longitude: venusLong))

        // Mars
        let marsLong = normalizeAngle(marsLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .mars, longitude: marsLong))

        // Jupiter
        let jupiterLong = normalizeAngle(jupiterLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .jupiter, longitude: jupiterLong))

        // Saturn
        let saturnLong = normalizeAngle(saturnLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .saturn, longitude: saturnLong))

        // Uranus
        let uranusLong = normalizeAngle(uranusLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .uranus, longitude: uranusLong))

        // Neptune
        let neptuneLong = normalizeAngle(neptuneLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .neptune, longitude: neptuneLong))

        // Pluto
        let plutoLong = normalizeAngle(plutoLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .pluto, longitude: plutoLong))

        // North Node (mean)
        let nodeLong = normalizeAngle(northNodeLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .northNode, longitude: nodeLong))

        // Chiron (approximate)
        let chironLong = normalizeAngle(chironLongitude(T: T))
        positions.append(PlanetaryPosition(planet: .chiron, longitude: chironLong))

        // Ascendant (requires latitude/longitude and local sidereal time)
        let lst = localSiderealTime(jd: jd, longitude: longitude)
        let ascLong = normalizeAngle(ascendantLongitude(lst: lst, latitude: latitude))
        positions.append(PlanetaryPosition(planet: .ascendant, longitude: ascLong))

        // Midheaven
        let mcLong = normalizeAngle(midheavenLongitude(lst: lst))
        positions.append(PlanetaryPosition(planet: .midheaven, longitude: mcLong))

        return positions
    }

    // MARK: - Simplified Orbital Calculations

    private func sunLongitude(T: Double) -> Double {
        // Mean longitude
        let L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T
        // Mean anomaly
        let M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T
        let Mrad = M * .pi / 180.0
        // Equation of center
        let C = (1.914602 - 0.004817 * T) * sin(Mrad)
            + (0.019993 - 0.000101 * T) * sin(2 * Mrad)
            + 0.000289 * sin(3 * Mrad)
        return L0 + C
    }

    private func moonLongitude(T: Double) -> Double {
        let L0 = 218.3165 + 481267.8813 * T
        let M = 134.963 + 477198.8676 * T
        let Mrad = M * .pi / 180.0
        let D = 297.8502 + 445267.1115 * T
        let Drad = D * .pi / 180.0
        let F = 93.272 + 483202.0175 * T
        let Frad = F * .pi / 180.0

        let correction = 6.289 * sin(Mrad)
            - 1.274 * sin(2 * Drad - Mrad)
            + 0.658 * sin(2 * Drad)
            + 0.214 * sin(2 * Mrad)
            - 0.186 * sin((357.529 + 35999.050 * T) * .pi / 180.0)

        return L0 + correction
    }

    private func mercuryLongitude(T: Double) -> Double {
        let L = 252.2509 + 149472.6746 * T
        let M = 174.7948 + 149472.5153 * T
        let Mrad = M * .pi / 180.0
        return L + 23.44 * sin(Mrad) + 2.9818 * sin(2 * Mrad)
    }

    private func isMercuryRetrograde(T: Double) -> Bool {
        // Simplified: Mercury retrogrades ~3 times per year
        let dayInYear = (T * 365.25).truncatingRemainder(dividingBy: 365.25)
        let retroPeriods: [(start: Double, end: Double)] = [
            (20, 42), (120, 142), (220, 242), (320, 342)
        ]
        return retroPeriods.contains { dayInYear >= $0.start && dayInYear <= $0.end }
    }

    private func venusLongitude(T: Double) -> Double {
        let L = 181.9798 + 58517.8157 * T
        let M = 50.4161 + 58517.8039 * T
        let Mrad = M * .pi / 180.0
        return L + 0.7758 * sin(Mrad)
    }

    private func marsLongitude(T: Double) -> Double {
        let L = 355.433 + 19140.2993 * T
        let M = 19.373 + 19139.8585 * T
        let Mrad = M * .pi / 180.0
        return L + 10.691 * sin(Mrad) + 0.623 * sin(2 * Mrad)
    }

    private func jupiterLongitude(T: Double) -> Double {
        let L = 34.351 + 3034.9057 * T
        let M = 20.020 + 3034.6874 * T
        let Mrad = M * .pi / 180.0
        return L + 5.555 * sin(Mrad) + 0.168 * sin(2 * Mrad)
    }

    private func saturnLongitude(T: Double) -> Double {
        let L = 50.077 + 1222.1138 * T
        let M = 317.021 + 1222.1116 * T
        let Mrad = M * .pi / 180.0
        return L + 6.406 * sin(Mrad) + 0.318 * sin(2 * Mrad)
    }

    private func uranusLongitude(T: Double) -> Double {
        let L = 314.055 + 428.4669 * T
        let M = 142.543 + 428.4677 * T
        let Mrad = M * .pi / 180.0
        return L + 5.312 * sin(Mrad)
    }

    private func neptuneLongitude(T: Double) -> Double {
        let L = 304.349 + 218.4862 * T
        let M = 256.225 + 218.4862 * T
        let Mrad = M * .pi / 180.0
        return L + 0.981 * sin(Mrad)
    }

    private func plutoLongitude(T: Double) -> Double {
        let L = 238.929 + 145.1781 * T
        let M = 25.084 + 145.1781 * T
        let Mrad = M * .pi / 180.0
        return L + 14.882 * sin(Mrad)
    }

    private func northNodeLongitude(T: Double) -> Double {
        // Mean North Node (retrograde motion)
        return 125.0445 - 1934.1363 * T
    }

    private func chironLongitude(T: Double) -> Double {
        // Very approximate - Chiron's orbit is complex
        let L = 209.0 + 7.167 * T * 36525.0 / 50.76
        return L
    }

    // MARK: - House Calculations (Placidus Simplified)

    private func ascendantLongitude(lst: Double, latitude: Double) -> Double {
        let lstRad = lst * .pi / 180.0
        let latRad = latitude * .pi / 180.0
        let obliquity = 23.4393 * .pi / 180.0

        let y = -cos(lstRad)
        let x = sin(obliquity) * tan(latRad) + cos(obliquity) * sin(lstRad)
        var asc = atan2(y, x) * 180.0 / .pi

        if asc < 0 { asc += 360.0 }
        return asc
    }

    private func midheavenLongitude(lst: Double) -> Double {
        let lstRad = lst * .pi / 180.0
        let obliquity = 23.4393 * .pi / 180.0

        var mc = atan2(sin(lstRad), cos(lstRad) * cos(obliquity)) * 180.0 / .pi
        if mc < 0 { mc += 360.0 }
        return mc
    }

    func calculateHouses(date: Date, latitude: Double, longitude: Double) -> [House] {
        let jd = julianDay(from: date)
        let lst = localSiderealTime(jd: jd, longitude: longitude)
        let ascDeg = normalizeAngle(ascendantLongitude(lst: lst, latitude: latitude))

        // Simplified equal house system (30 degrees per house from ascendant)
        return (1...12).map { houseNum in
            let cusp = normalizeAngle(ascDeg + Double(houseNum - 1) * 30.0)
            return House(number: houseNum, cuspDegree: cusp)
        }
    }

    // MARK: - Aspect Calculations

    func calculateAspects(planets: [PlanetaryPosition]) -> [Aspect] {
        var aspects: [Aspect] = []
        let celestialBodies = planets.filter { $0.planet != .ascendant && $0.planet != .midheaven }

        for i in 0..<celestialBodies.count {
            for j in (i + 1)..<celestialBodies.count {
                let p1 = celestialBodies[i]
                let p2 = celestialBodies[j]

                let angle = angleBetween(p1.longitude, p2.longitude)

                for aspectType in AspectType.allCases {
                    let orb = abs(angle - aspectType.angle)
                    if orb <= aspectType.orb {
                        aspects.append(Aspect(
                            planet1: p1.planet,
                            planet2: p2.planet,
                            type: aspectType,
                            exactAngle: angle,
                            orb: orb
                        ))
                    }
                }
            }
        }

        return aspects
    }

    // MARK: - Transit Calculations

    func calculateCurrentTransits(natalChart: NatalChart) -> [Transit] {
        let now = Date()
        let currentPositions = calculatePlanetaryPositions(date: now, latitude: 0, longitude: 0)
        var transits: [Transit] = []

        let transitPlanets: [Planet] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn]

        for currentPos in currentPositions where transitPlanets.contains(currentPos.planet) {
            for natalPos in natalChart.planets where natalPos.planet != .ascendant && natalPos.planet != .midheaven {
                let angle = angleBetween(currentPos.longitude, natalPos.longitude)

                for aspectType in AspectType.allCases {
                    let orb = abs(angle - aspectType.angle)
                    if orb <= aspectType.orb * 0.6 { // tighter orbs for transits
                        let description = transitDescription(
                            transitPlanet: currentPos.planet,
                            natalPlanet: natalPos.planet,
                            aspectType: aspectType
                        )

                        transits.append(Transit(
                            planet: currentPos.planet,
                            sign: currentPos.sign,
                            aspectType: aspectType,
                            natalPlanet: natalPos.planet,
                            description: description,
                            startDate: now.addingTimeInterval(-86400 * 3),
                            endDate: now.addingTimeInterval(86400 * 3),
                            intensity: 1.0 - (orb / aspectType.orb)
                        ))
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.currentTransits = transits.sorted { $0.intensity > $1.intensity }
        }

        return transits
    }

    private func transitDescription(transitPlanet: Planet, natalPlanet: Planet, aspectType: AspectType) -> String {
        let verb: String
        switch aspectType {
        case .conjunction: verb = "merges with"
        case .sextile: verb = "harmonizes with"
        case .square: verb = "challenges"
        case .trine: verb = "flows with"
        case .opposition: verb = "illuminates"
        }
        return "Transiting \(transitPlanet.name) \(verb) your natal \(natalPlanet.name)"
    }

    // MARK: - Moon Phase

    func calculateMoonPhase(date: Date = Date()) -> MoonPhase {
        let jd = julianDay(from: date)
        let T = (jd - 2451545.0) / 36525.0

        let sunLong = self.sunLongitude(T: T)
        let moonLong = self.moonLongitude(T: T)

        let phase = normalizeAngle(moonLong - sunLong)

        let result: MoonPhase
        switch phase {
        case 0..<22.5: result = .newMoon
        case 22.5..<67.5: result = .waxingCrescent
        case 67.5..<112.5: result = .firstQuarter
        case 112.5..<157.5: result = .waxingGibbous
        case 157.5..<202.5: result = .fullMoon
        case 202.5..<247.5: result = .waningGibbous
        case 247.5..<292.5: result = .lastQuarter
        case 292.5..<337.5: result = .waningCrescent
        default: result = .newMoon
        }

        DispatchQueue.main.async {
            self.currentMoonPhase = result
        }

        return result
    }

    // MARK: - Utility Functions

    private func julianDay(from date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)

        var y = Double(comps.year ?? 2000)
        var m = Double(comps.month ?? 1)
        let d = Double(comps.day ?? 1)
            + Double(comps.hour ?? 0) / 24.0
            + Double(comps.minute ?? 0) / 1440.0

        if m <= 2 {
            y -= 1
            m += 12
        }

        let A = floor(y / 100.0)
        let B = 2 - A + floor(A / 4.0)

        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + B - 1524.5
    }

    private func localSiderealTime(jd: Double, longitude: Double) -> Double {
        let T = (jd - 2451545.0) / 36525.0
        var lst = 280.46061837 + 360.98564736629 * (jd - 2451545.0)
            + 0.000387933 * T * T
        lst += longitude
        return normalizeAngle(lst)
    }

    private func normalizeAngle(_ angle: Double) -> Double {
        var a = angle.truncatingRemainder(dividingBy: 360.0)
        if a < 0 { a += 360.0 }
        return a
    }

    private func angleBetween(_ a: Double, _ b: Double) -> Double {
        var diff = abs(a - b)
        if diff > 180 { diff = 360 - diff }
        return diff
    }

    // MARK: - Sample / Demo Chart

    static func sampleChart() -> NatalChart {
        let calculator = ChartCalculator()
        let birthDate = Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15, hour: 14, minute: 30))!
        return calculator.calculateChart(
            birthDate: birthDate,
            birthPlace: "New York, NY",
            latitude: 40.7128,
            longitude: -74.0060
        )
    }
}
