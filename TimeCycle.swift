import SwiftUI

struct TimeCycleScreen: View {
    @State private var selectedHour: Int = 7
    @State private var selectedMinute: Int = 30
    @State private var isAM: Bool = true
    @State private var timeOfDay: TimeOfDay = .morning

    @State private var celestialProgress: CGFloat = 0.3
    @State private var sliderValue: Double = 7.5
    @State private var transitionOpacity: Double = 1.0
    
    var formattedTime: String {
        let displayHour = selectedHour == 0 ? 12 : selectedHour
        return String(format: "%d:%02d", displayHour, selectedMinute)
    }
    
    var formattedAMPM: String {
        return isAM ? "AM" : "PM"
    }
    
    var body: some View {
        ZStack {
            TimeBackgroundView(timeOfDay: timeOfDay, progress: celestialProgress)
                .animation(.easeInOut(duration: 1.5), value: timeOfDay)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(formattedTime)
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 2)
                    
                    Text(formattedAMPM)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        .padding(.top, 5)
                }
                .opacity(transitionOpacity)
                .frame(height: 90)
                
                Text(timeOfDay.displayName)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 5)
                    .opacity(transitionOpacity)
                
                Spacer()
                
                CelestialTransitionView(
                    hour: selectedHour + (isAM ? 0 : 12),
                    minute: selectedMinute,
                    timeOfDay: timeOfDay,
                    progress: celestialProgress
                )
                .frame(height: 120)
                .opacity(transitionOpacity)
                
                Spacer()
                
                TimeSlider(
                    value: $sliderValue,
                    timeOfDay: $timeOfDay,
                    selectedHour: $selectedHour,
                    selectedMinute: $selectedMinute,
                    isAM: $isAM,
                    celestialProgress: $celestialProgress,
                    transitionOpacity: $transitionOpacity
                )
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBarHidden()
        .onAppear {
            updateTimeOfDay()
        }
    }
    
    private func updateTimeOfDay() {
        let hour = selectedHour + (isAM ? 0 : 12)
        if hour >= 5 && hour < 8 {
            timeOfDay = .dawn
            celestialProgress = CGFloat((hour - 5) * 60 + selectedMinute) / 180
        } else if hour >= 8 && hour < 11 {
            timeOfDay = .morning
            celestialProgress = CGFloat((hour - 8) * 60 + selectedMinute) / 180
        } else if hour >= 11 && hour < 14 {
            timeOfDay = .noon
            celestialProgress = CGFloat((hour - 11) * 60 + selectedMinute) / 180
        } else if hour >= 14 && hour < 18 {
            timeOfDay = .afternoon
            celestialProgress = CGFloat((hour - 14) * 60 + selectedMinute) / 240
        } else if hour >= 18 && hour < 21 {
            timeOfDay = .evening
            celestialProgress = CGFloat((hour - 18) * 60 + selectedMinute) / 180
        } else {
            timeOfDay = .night
            celestialProgress = hour < 5 ? CGFloat((hour + 3) * 60 + selectedMinute) / 480 :
                                          CGFloat((hour - 21) * 60 + selectedMinute) / 480
        }
    }
}


enum TimeOfDay: Equatable {
    case dawn, morning, noon, afternoon, evening, night
    
    var accentColor: Color {
        switch self {
        case .dawn: return Color.orange
        case .morning: return Color.yellow
        case .noon: return Color.yellow
        case .afternoon: return Color.orange
        case .evening: return Color.purple
        case .night: return Color.indigo
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .dawn:
            return [Color(red: 0.7, green: 0.4, blue: 0.5),
                    Color(red: 0.9, green: 0.6, blue: 0.4),
                    Color(red: 0.95, green: 0.8, blue: 0.6)]
        case .morning:
            return [Color(red: 0.6, green: 0.8, blue: 0.95),
                    Color(red: 0.7, green: 0.9, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0)]
        case .noon:
            return [Color(red: 0.4, green: 0.75, blue: 0.95),
                    Color(red: 0.6, green: 0.85, blue: 1.0),
                    Color(red: 0.7, green: 0.9, blue: 1.0)]
        case .afternoon:
            return [Color(red: 0.5, green: 0.7, blue: 0.9),
                    Color(red: 0.7, green: 0.8, blue: 0.95),
                    Color(red: 0.9, green: 0.9, blue: 0.95)]
        case .evening:
            return [Color(red: 0.2, green: 0.2, blue: 0.5),
                    Color(red: 0.6, green: 0.3, blue: 0.6),
                    Color(red: 0.8, green: 0.5, blue: 0.5)]
        case .night:
            return [Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.15, blue: 0.4)]
        }
    }
    
    var displayName: String {
        switch self {
        case .dawn: return "Dawn"
        case .morning: return "Morning"
        case .noon: return "Noon"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
}

struct TimeBackgroundView: View {
    let timeOfDay: TimeOfDay
    let progress: CGFloat
    @State private var starOpacity: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: timeOfDay.gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Group {
                if timeOfDay == .evening || timeOfDay == .night {
                    StarsView(opacity: starOpacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 2.0)) {
                                starOpacity = 1.0
                            }
                        }
                } else if timeOfDay == .dawn {
                    StarsView(opacity: max(0, 1.0 - progress * 2))
                }
            }
            .animation(.easeInOut(duration: 1.5), value: timeOfDay)

            if timeOfDay == .dawn || timeOfDay == .morning ||
               timeOfDay == .noon || timeOfDay == .afternoon {
                ReducedCloudsView()
                    .opacity(timeOfDay == .dawn ? 0.5 :
                             timeOfDay == .afternoon ? 0.7 : 0.8)
            }
        }
    }
}

struct StarsView: View {
    let opacity: Double
    let starCount = 200
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<starCount, id: \.self) { index in
                    let size = CGFloat.random(in: 1...3)
                    let position = CGPoint(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
                    let opacity = Double.random(in: 0.5...1.0)
                    let twinkleSpeed = Double.random(in: 1.0...3.0)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: size, height: size)
                        .position(position)
                        .opacity(opacity)
                        .modifier(EnhancedTwinkleEffect(speed: twinkleSpeed))
                }
                
                ForEach(0..<20, id: \.self) { index in
                    let size = CGFloat.random(in: 2...4)
                    let position = CGPoint(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height * 0.8)
                    )
                    
                    StarShape()
                        .fill(Color.white)
                        .frame(width: size * 3, height: size * 3)
                        .position(position)
                        .modifier(EnhancedTwinkleEffect(speed: Double.random(in: 1.5...2.5)))
                }
                
                ShootingStarsView()
            }
        }
        .opacity(opacity)
    }
}

struct EnhancedTwinkleEffect: ViewModifier {
    let speed: Double
    @State private var opacity: Double = Double.random(in: 0.5...1.0)
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                let opacityAnimation = Animation.easeInOut(duration: speed)
                    .repeatForever(autoreverses: true)
                
                let scaleAnimation = Animation.easeInOut(duration: speed * 1.2)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...1))
                
                withAnimation(opacityAnimation) {
                    opacity = Double.random(in: 0.2...0.7)
                }
                
                withAnimation(scaleAnimation) {
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}

struct ReducedCloudsView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                CloudGroup()
                    .frame(width: 200, height: 100)
                    .position(x: geo.size.width * 0.2, y: geo.size.height * 0.25)
                    .opacity(0.7)
                
                CloudGroup()
                    .frame(width: 300, height: 150)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.4)
                    .opacity(0.6)
                
                CloudGroup()
                    .frame(width: 250, height: 120)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.15)
                    .opacity(0.8)
                
                CloudGroup()
                    .frame(width: 220, height: 110)
                    .position(x: geo.size.width * 0.3, y: geo.size.height * 0.6)
                    .opacity(0.5)
            }
        }
    }
}

struct ShootingStarsView: View {
    @State private var shootingStarOffset: CGFloat = -300
    @State private var shootingStarOpacity: Double = 0
    @State private var nextStarDelay: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            let startPoint = CGPoint(
                x: CGFloat.random(in: 0...geo.size.width),
                y: CGFloat.random(in: 0...geo.size.height/3)
            )
            
            ShootingStar()
                .position(startPoint)
                .offset(x: shootingStarOffset, y: shootingStarOffset)
                .opacity(shootingStarOpacity)
                .onAppear {
                    startShootingStarAnimation(in: geo)
                }
        }
    }
    
    func startShootingStarAnimation(in geo: GeometryProxy) {
        nextStarDelay = Double.random(in: 3...15)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + nextStarDelay) {
            withAnimation(.easeOut(duration: 0.8)) {
                shootingStarOpacity = 1.0
                shootingStarOffset = 300
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                shootingStarOpacity = 0
                shootingStarOffset = -300
                startShootingStarAnimation(in: geo)
            }
        }
    }
}

struct ShootingStar: View {
    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .white.opacity(0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: 20)
                .offset(y: -2)
        }
        .rotationEffect(Angle(degrees: 45))
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5
        var path = Path()
        
        for i in 0..<points * 2 {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = Double(i) * .pi / Double(points)
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct CloudGroup: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.8))
                .frame(width: 120, height: 60)
                .offset(x: 20, y: 10)
            
            Capsule()
                .fill(Color.white.opacity(0.8))
                .frame(width: 90, height: 40)
                .offset(x: -30, y: 20)
            
            Capsule()
                .fill(Color.white)
                .frame(width: 110, height: 50)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct CelestialTransitionView: View {
    let hour: Int
    let minute: Int
    let timeOfDay: TimeOfDay
    let progress: CGFloat
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            if timeOfDay == .dawn {
                MoonView(progress: 0.9)
                    .offset(y: 100 + progress * 200)
                    .opacity(max(0, 1.0 - progress * 2))
                
                SunView(progress: progress, color: .orange)
                    .offset(y: 300 - progress * 400)
                    .opacity(min(1, progress * 2))
            }

            else if timeOfDay == .morning {
                SunView(progress: progress, color: .yellow)
                    .offset(y: -50 - progress * 50)
            }
            else if timeOfDay == .noon {
                SunView(progress: progress, color: .yellow)
                    .offset(y: -100)
            }
            else if timeOfDay == .afternoon {
                SunView(progress: progress, color: .orange)
                    .offset(y: -100 + progress * 150)
            }

            else if timeOfDay == .evening {

                SunView(progress: 1 - progress, color: .orange)
                    .offset(y: 50 + progress * 200)
                    .opacity(max(0, 1.0 - progress * 1.5))
                
                if progress > 0.3 {
                    MoonView(progress: (progress - 0.3) / 0.7)
                        .offset(y: 300 - ((progress - 0.3) / 0.7) * 300)
                        .opacity(min(1, (progress - 0.3) * 3.0))
                }
            }

            else if timeOfDay == .night {
                MoonView(progress: progress)
                    .offset(y: -50 + progress * 150)
            }
        }
        .scaleEffect(pulseScale)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}


struct SunView: View {
    let progress: CGFloat
    let color: Color
    @State private var isAnimating: Bool = false
    @State private var rayScale: CGFloat = 1.0
    @State private var rayRotation: Double = 0
    
    var body: some View {
        ZStack {

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.5), color.opacity(0)]),
                        center: .center,
                        startRadius: 30,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .scaleEffect(isAnimating ? 1.1 : 1.0)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white, color]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: color, radius: 15, x: 0, y: 0)
            
            ForEach(0..<12, id: \.self) { i in
                RayShape()
                    .stroke(color, lineWidth: i.isMultiple(of: 2) ? 3 : 2)
                    .frame(width: 120, height: 120)
                    .rotationEffect(Angle(degrees: Double(i) * 30 + rayRotation))
                    .scaleEffect(rayScale)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isAnimating = true
                rayScale = 1.1
            }
            
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                rayRotation = 360
            }
        }
    }
}

struct RayShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * 0.4
        let outerRadius = radius * 0.9
        
        var path = Path()
        
        path.move(to: CGPoint(
            x: center.x + innerRadius * cos(0),
            y: center.y + innerRadius * sin(0)
        ))
        
        path.addLine(to: CGPoint(
            x: center.x + outerRadius * cos(0),
            y: center.y + outerRadius * sin(0)
        ))
        
        return path
    }
}

struct MoonView: View {
    let progress: CGFloat
    @State private var glowOpacity: Double = 0.7
    @State private var craterOpacity: Double = 0.2
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white.opacity(0.8), .white.opacity(0.3), .white.opacity(0)]),
                        center: .center,
                        startRadius: 25,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .opacity(glowOpacity)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.white.opacity(0.95), .white.opacity(0.8)]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)

                Group {
                    Circle()
                        .fill(Color.gray.opacity(craterOpacity))
                        .frame(width: 15, height: 15)
                        .offset(x: 15, y: -10)
                    
                    Circle()
                        .fill(Color.gray.opacity(craterOpacity + 0.05))
                        .frame(width: 12, height: 12)
                        .offset(x: -10, y: 15)
                    
                    Circle()
                        .fill(Color.gray.opacity(craterOpacity - 0.05))
                        .frame(width: 10, height: 10)
                        .offset(x: -15, y: -15)
                }
                
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 55, height: 55)
                    .offset(x: -25 + (50 * progress), y: 0)
                    .mask(
                        Circle()
                            .frame(width: 60, height: 60)
                    )
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowOpacity = 0.5
                craterOpacity = 0.3
            }
        }
    }
}

struct TimeSlider: View {
    @Binding var value: Double
    @Binding var timeOfDay: TimeOfDay
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var isAM: Bool
    @Binding var celestialProgress: CGFloat
    @Binding var transitionOpacity: Double
    
    @State private var isDragging: Bool = false
    @State private var indicatorScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                ForEach(0..<24, id: \.self) { hour in
                    TimeIndicator(
                        hour: hour,
                        isSelected: hour == Int(value),
                        timeColor: timeOfDay.accentColor
                    )
                }
            }
            .padding(.horizontal, 10)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                timeOfDay.accentColor.opacity(0.8),
                                timeOfDay.accentColor
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(calculateProgress() * (UIScreen.main.bounds.width - 60), UIScreen.main.bounds.width - 60)), height: 8)

                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(timeOfDay.accentColor, lineWidth: 3)
                    )
                    .scaleEffect(indicatorScale)
                    .offset(x: calculateIndicatorOffset())
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            indicatorScale = 1.2
                            transitionOpacity = 0.7
                        }
                        
                        let width = UIScreen.main.bounds.width - 60
                        let xPos = max(0, min(value.location.x, width))
                        let percentage = xPos / width

                        self.value = percentage * 24

                        updateTimeWithTransition()
                    }
                    .onEnded { _ in
                        isDragging = false
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            indicatorScale = 1.0
                            transitionOpacity = 1.0
                        }
                    }
            )

            HStack {
                Text("12 AM")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 50, alignment: .leading)
                
                Spacer()
                
                Text("6 AM")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("12 PM")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("6 PM")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("12 AM")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.horizontal, 10)
        }
    }
    
    private func calculateProgress() -> CGFloat {
        return CGFloat(value / 24.0)
    }
    
    private func calculateIndicatorOffset() -> CGFloat {
        let trackWidth = UIScreen.main.bounds.width - 60
        let progress = calculateProgress()
        let position = progress * trackWidth
        return position - 14
    }
    
    private func updateTimeWithTransition() {
        // Fade out current time
        withAnimation(.easeOut(duration: 0.2)) {
            transitionOpacity = 0.7
        }
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let totalHours = self.value
            let hour24 = Int(totalHours) % 24
            

            let hour12 = hour24 % 12
            let isAMNew = hour24 < 12
            
            self.selectedHour = hour12
            self.selectedMinute = Int((totalHours - Double(Int(totalHours))) * 60)
            self.isAM = isAMNew
            

            self.updateTimeOfDay()
            

            withAnimation(.easeIn(duration: 0.3)) {
                self.transitionOpacity = 1.0
            }
        }
    }
    
    private func updateTimeOfDay() {
        let hour = selectedHour + (isAM ? 0 : 12)
        if hour >= 5 && hour < 8 {
            timeOfDay = .dawn
            celestialProgress = CGFloat((hour - 5) * 60 + selectedMinute) / 180
        } else if hour >= 8 && hour < 11 {
            timeOfDay = .morning
            celestialProgress = CGFloat((hour - 8) * 60 + selectedMinute) / 180
        } else if hour >= 11 && hour < 14 {
            timeOfDay = .noon
            celestialProgress = CGFloat((hour - 11) * 60 + selectedMinute) / 180
        } else if hour >= 14 && hour < 18 {
            timeOfDay = .afternoon
            celestialProgress = CGFloat((hour - 14) * 60 + selectedMinute) / 240
        } else if hour >= 18 && hour < 21 {
            timeOfDay = .evening
            celestialProgress = CGFloat((hour - 18) * 60 + selectedMinute) / 180
        } else {
            timeOfDay = .night
            celestialProgress = hour < 5 ? CGFloat((hour + 3) * 60 + selectedMinute) / 480 :
                                          CGFloat((hour - 21) * 60 + selectedMinute) / 480
        }
    }
}


struct TimeIndicator: View {
    let hour: Int
    let isSelected: Bool
    let timeColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Rectangle()
                .fill(isSelected ? timeColor : Color.white.opacity(0.4))
                .frame(width: 2, height: isSelected ? 12 : 8)
                .animation(.spring(response: 0.3), value: isSelected)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TimeCycleScreen()
}
