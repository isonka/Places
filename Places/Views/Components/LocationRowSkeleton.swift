import SwiftUI

struct LocationRowSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(skeletonGradient)
                .frame(width: 48, height: 48)            
            VStack(alignment: .leading, spacing: 6) {                
                RoundedRectangle(cornerRadius: 4)
                    .fill(skeletonGradient)
                    .frame(width: 150, height: 20)
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(skeletonGradient)
                        .frame(width: 80, height: 16)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(skeletonGradient)
                        .frame(width: 80, height: 16)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
    
    private var skeletonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemGray5),
                Color(.systemGray6),
                Color(.systemGray5)
            ],
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}

struct LocationsListSkeleton: View {
    let count: Int
    
    var body: some View {
        Section(header: Text("Places")) {
            ForEach(0..<count, id: \.self) { _ in
                LocationRowSkeleton()
            }
        }
    }
}

// MARK: - Preview

#Preview("Single Skeleton") {
    List {
        LocationRowSkeleton()
    }
}

#Preview("Multiple Skeletons") {
    List {
        LocationsListSkeleton(count: 5)
    }
}

