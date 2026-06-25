import Foundation

struct ModelStatistics {
    let totalModels: Int
    let totalSize: Int64
    let byEngine: [(String, Int, Int64)]
    let largestModel: AIModel?
    let smallestModel: AIModel?

    init(models: [AIModel]) {
        totalModels = models.count
        totalSize = models.reduce(0) { $0 + $1.size }

        var engineCounts: [String: (Int, Int64)] = [:]
        for m in models {
            let curr = engineCounts[m.engine] ?? (0, 0)
            engineCounts[m.engine] = (curr.0 + 1, curr.1 + m.size)
        }
        byEngine = engineCounts.map { ($0.key, $0.value.0, $0.value.1) }
            .sorted { $0.2 > $1.2 }

        largestModel = models.max(by: { $0.size < $1.size })
        smallestModel = models.filter { $0.size > 0 }.min(by: { $0.size < $1.size })
    }
}
