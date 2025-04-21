#[derive(Copy, Clone)]
pub struct Decoder;

impl toml_test_harness::Decoder for Decoder {
    fn name(&self) -> &str {
        "toml"
    }

    fn decode(
        &self,
        data: &[u8],
    ) -> Result<toml_test_harness::DecodedValue, toml_test_harness::Error> {
        let data = std::str::from_utf8(data).map_err(toml_test_harness::Error::new)?;
        let table = boml::Toml::parse(&data)
            .map_err(|err| toml_test_harness::Error::new(format!("{err:?}")))?
            .into();
        table_to_decoded(&table)
    }
}

fn value_to_decoded(
    value: &boml::types::TomlValue,
) -> Result<toml_test_harness::DecodedValue, toml_test_harness::Error> {
    match value {
        boml::types::TomlValue::Integer(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::from(*v),
        )),
        boml::types::TomlValue::String(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::from(v.as_str()),
        )),
        boml::types::TomlValue::Float(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::from(*v),
        )),
        boml::types::TomlValue::OffsetDateTime(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::Datetime(render_offsetdatetime(v)),
        )),
        boml::types::TomlValue::DateTime(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::DatetimeLocal(render_datetime(v)),
        )),
        boml::types::TomlValue::Date(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::DateLocal(render_date(v)),
        )),
        boml::types::TomlValue::Time(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::TimeLocal(render_time(v)),
        )),
        boml::types::TomlValue::Boolean(v) => Ok(toml_test_harness::DecodedValue::Scalar(
            toml_test_harness::DecodedScalar::from(*v),
        )),
        boml::types::TomlValue::Array(v, _) => {
            let v: Result<_, toml_test_harness::Error> = v.iter().map(value_to_decoded).collect();
            Ok(toml_test_harness::DecodedValue::Array(v?))
        }
        boml::types::TomlValue::Table(v) => table_to_decoded(v),
    }
}

fn table_to_decoded(
    value: &boml::table::TomlTable,
) -> Result<toml_test_harness::DecodedValue, toml_test_harness::Error> {
    let table: Result<_, toml_test_harness::Error> = value
        .iter()
        .map(|(k, v)| {
            let k = k.as_str().to_owned();
            let v = value_to_decoded(v)?;
            Ok((k, v))
        })
        .collect();
    Ok(toml_test_harness::DecodedValue::Table(table?))
}

fn render_offsetdatetime(value: &boml::types::OffsetTomlDateTime) -> String {
    format!(
        "{}t{}{}",
        render_date(&value.date),
        render_time(&value.time),
        render_offset(&value.offset)
    )
}

fn render_datetime(value: &boml::types::TomlDateTime) -> String {
    format!("{}t{}", render_date(&value.date), render_time(&value.time))
}

fn render_date(value: &boml::types::TomlDate) -> String {
    format!("{}-{}-{}", value.year, value.month, value.month_day)
}

fn render_time(value: &boml::types::TomlTime) -> String {
    format!(
        "{:2}:{:2}:{:2}.{}",
        value.hour, value.minute, value.second, value.nanosecond
    )
}

fn render_offset(value: &boml::types::TomlOffset) -> String {
    let prefix = if value.hour < 0 { "-" } else { "+" };
    format!("{prefix}{:2}:{:2}", value.hour.abs(), value.minute)
}
