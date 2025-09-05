//
//  ContentView.swift
//  Clock
//
//  Created by MAC on 2025/8/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack{
                //表盘背景和刻度
                ClockFaceView().frame(width: min(geo.size.width,geo.size.height),height: min(geo.size.width,geo.size.height))
                //指针（使用TimelineView获取连续时间）
                TimelineView(.animation){ timeline in
                    let date = timeline.date
                    let calendar = Calendar.current
                    let comps = calendar.dateComponents([.hour,.minute,.second,.nanosecond], from: date)
                    
                    let hour = comps.hour ?? 0
                    let minute = comps.minute ?? 0
                    let second = comps.second ?? 0
                    let nanosecond = comps.nanosecond ?? 0
                    //计算角度（度数）
                    let secondFraction = Double(second) + Double(nanosecond) / 1_000_000_000.0
                    let secondAngle = Angle.degrees(secondFraction * 6)
                    let minuteFraction = Double(minute) + secondFraction / 60.0
                    let minuteAngle = Angle.degrees(minuteFraction * 6)
                    let hourFraction = Double(hour % 12) + minuteFraction / 60.0
                    let hourAngle = Angle.degrees(hourFraction * 30)
                    
                    
                    ZStack{
                        //时针
                        ClockHand(lengthRatio: 0.5,lineWidth: 6,color: .red)
                            .rotationEffect(hourAngle)
                            .shadow(radius: 1)
                        //分针
                        ClockHand(lengthRatio: 0.8, lineWidth: 4,color:.gray)
                            .rotationEffect(minuteAngle)
                            .shadow(radius: 0.5)
                        //秒针
                        ClockHand(lengthRatio: 1, lineWidth: 1.6)
                            .rotationEffect(secondAngle)
                            .shadow(radius: 0.5)
                        //中心点
                        Circle().frame(width: 12, height: 12).foregroundStyle(.primary)
                    }
                    .frame(width: min(geo.size.width,geo.size.height),
                           height: min(geo.size.width,geo.size.height))
                }
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}
struct ClockFaceView:View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width,geo.size.height)
            let center = CGPoint(x: size/2, y: size/2)
            
            ZStack{
                // 背景
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color(.systemBackground),Color(.secondarySystemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .overlay(Circle().stroke(Color.primary.opacity(0.12),lineWidth: size*0.008))
                ForEach(0..<60) { tick in
                    Rectangle()
                        .fill(tick % 5 == 0 ? Color.primary :Color.primary.opacity(0.6))
                        .frame(width: tick % 5 == 0 ? 2 : 1, height: tick % 5 == 0 ? size * 0.07 : size * 0.04)
                        .offset(y:-size/2 + (tick % 5 == 0 ? size * 0.07/2 : size * 0.04/2) + size * 0.02)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }
                
                ForEach(1...12, id: \.self){ h in
                    Text("\(h)")
                        .font(.system(size: size*0.09,weight: .medium,design: .rounded))
                        .foregroundStyle(.primary)
                        .position(x:center.x + cos(CGFloat(h) * .pi/6 - .pi/2)*(size * 0.35),y:center.y + sin(CGFloat(h) * .pi/6 - .pi/2) * (size * 0.35))
                }
            }.frame(width: size, height: size)
        }
    }
}
struct ClockHand:View {
    var lengthRatio :CGFloat = 0.6
    var lineWidth :CGFloat = 4
    var color: Color = .primary

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let handHeight = size * lengthRatio / 2.0
            VStack{
                Rectangle()
                    .frame(width: lineWidth,height: handHeight)
                    .cornerRadius(lineWidth/2)
                    .offset(y:-handHeight/2 + lineWidth/2)
//                Spacer()
            }.frame(width: size,height: size)
                .rotationEffect(.degrees(0))
                .compositingGroup()
                .foregroundStyle(color)
                .drawingGroup()
        }
    }
}
#Preview {
    ContentView()
}
