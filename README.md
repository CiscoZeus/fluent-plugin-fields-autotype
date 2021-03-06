fluent-plugin-fields-autotype
===========================

Fluent output filter plugin for parsing key/value fields in records
based on configurable patterns. This plugin is a fork of tomas-zemres/fluent-plugin-fields-parser. We extend that plugin to automatically determine the data type of the value (string, integer or float).

## Installation

Use RubyGems:

    td-agent-gem install fluent-plugin-fields-autotype

## Configuration

    <match pattern>
        type                fields_autotype

        remove_tag_prefix   raw
        add_tag_prefix      parsed
        pattern             (\S+)=(\S+)
    </match>

If following record is passed:

```
{"message": "Audit log username=Johny action=add-user result=success" }
```

then you will get a new record:

```
{
    "message": "Audit log username=Johny action=add-user result=success",
    "username": "Johny",
    "action": "add-user",
    "result": "success"
}
```

### Parameter parse_key

For configuration

    <match pattern>
        type        fields_autotype

        parse_key   log_message
    </match>

it parses key "log_message" instead of default key `message`.

### Parameter fields_key

Configuration

    <match pattern>
        type        fields_autotype

        parse_key   log_message
        fields_key  fields
    </match>

For input like:

```
{
    "log_message": "Audit log username=Johny action=add-user result=success",
}
```

it adds parsed fields into defined key.

```
{
    "log_message": "Audit log username=Johny action='add-user' result=success",
    "fields": {"user": "Johny", "action": "add-user", "result": "success"}
}
```

(It adds new keys into top-level record by default.)

### Parameter pattern

You can define custom pattern (regexp) for seaching keys/values. Data type like float and int are automatically determined.

Configuration

    <match pattern>
        type        fields_autotype

        pattern     (\w+):(\S+)
    </match>

For input like:
```
{ "message": "black:54 white:55 red:10.1"}
```

it returns:

```
{ "message": "black:54 white=55 red=10.1",
  "black": 54, "white": 55, "red": 10.1
}
```

### Tag prefix

You cat add and/or remove tag prefix using Configuration parameters

    <match pattern>
        type                fields_autotype

        remove_tag_prefix   raw
        add_tag_prefix      parsed
    </match>

If it matched tag "raw.some.record", then it emits tag "parsed.some.record".

