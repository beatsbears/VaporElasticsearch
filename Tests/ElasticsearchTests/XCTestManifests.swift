import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ElasticsearchTests.allTests),
        testCase(ElasticsearchQueryCodingTests.allTests),
        testCase(ElasticsearchAggregationCodingTests.allTests),
        testCase(NormalizerTests.allTests),
        testCase(TokenizerTests.allTests),
        testCase(CharacterFilterTests.allTests),
        testCase(AnalyzerTests.allTests)
    ]
}
#endif
