/*
resource "aws_wafregional_rule" "bot-example-route-control-rule" {
  name = "MatchBotsAndExampleRoute"
  metric_name = "MatchBotsAndExampleRoute"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.example.id}"
    negated = false
    type = "ByteMatch"
  }
}
resource "aws_wafregional_byte_match_set" "example" {
  name = "MatchBotInUserAgent"
  byte_match_tuples {
    text_transformation   = "NONE"
    target_string         = "badrefer1"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "referer"
    }
  }
}
*/