use taplo::dom::node::Node;

#[derive(Copy, Clone)]
pub struct Decoder;

impl toml_test_harness::Decoder for Decoder {
    fn name(&self) -> &str {
        "taplo"
    }

    fn decode(
        &self,
        data: &[u8],
    ) -> Result<toml_test_harness::DecodedValue, toml_test_harness::Error> {
        use std::fmt::Write as _;

        let data = std::str::from_utf8(data).map_err(toml_test_harness::Error::new)?;
        let parsed = taplo::parser::parse(data);
        if !parsed.errors.is_empty() {
            let mut message = String::new();
            for error in parsed.errors {
                writeln!(&mut message, "{error}").unwrap();
            }
            return Err(toml_test_harness::Error::new(message));
        }
        let node = parsed.into_dom();
        if let Err(errors) = node.validate() {
            let mut message = String::new();
            for error in errors {
                writeln!(&mut message, "{error}").unwrap();
            }
            return Err(toml_test_harness::Error::new(message));
        }
        value_to_decoded(&node)
    }
}

fn value_to_decoded(
    value: &Node,
) -> Result<toml_test_harness::DecodedValue, toml_test_harness::Error> {
    match value {
        Node::Integer(v) => {
            let v = v.value();
            let v = match v {
                taplo::dom::node::IntegerValue::Positive(v) => {
                    toml_test_harness::DecodedScalar::Integer(v.to_string())
                }
                taplo::dom::node::IntegerValue::Negative(v) => {
                    toml_test_harness::DecodedScalar::from(v)
                }
            };
            Ok(toml_test_harness::DecodedValue::Scalar(v))
        }
        Node::Str(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::from(v.value()),
        )),
        Node::Float(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::from(v.value()),
        )),
        Node::Date(v) => {
            let v = v.value();
            let rendered = v.to_string();
            let v = match v {
                taplo::dom::node::DateTimeValue::OffsetDateTime(_) => {
                    toml_test_harness::DecodedScalar::Datetime(rendered)
                }
                taplo::dom::node::DateTimeValue::LocalDateTime(_) => {
                    toml_test_harness::DecodedScalar::DatetimeLocal(rendered)
                }
                taplo::dom::node::DateTimeValue::Date(_) => {
                    toml_test_harness::DecodedScalar::DateLocal(rendered)
                }
                taplo::dom::node::DateTimeValue::Time(_) => {
                    toml_test_harness::DecodedScalar::TimeLocal(rendered)
                }
            };
            Ok(toml_test_harness::DecodedValue::Scalar(v))
        }
        Node::Bool(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::from(v.value()),
        )),
        Node::Array(v) => {
            let v: Result<_, toml_test_harness::Error> =
                v.items().read().iter().map(value_to_decoded).collect();
            Ok(toml_test_harness::DecodedValue::Array(v?))
        }
        Node::Table(v) => table_to_decoded(v),
        Node::Invalid(_) => unreachable!("validation should prevent this"),
    }
}

fn table_to_decoded(
    value: &taplo::dom::node::Table,
) -> Result<toml_test_harness::DecodedValue, toml_test_harness::Error> {
    let table: Result<_, toml_test_harness::Error> = value
        .entries()
        .read()
        .iter()
        .map(|(k, v)| {
            let k = k.value().to_owned();
            let v = value_to_decoded(v)?;
            Ok((k, v))
        })
        .collect();
    Ok(toml_test_harness::DecodedValue::Table(table?))
}
