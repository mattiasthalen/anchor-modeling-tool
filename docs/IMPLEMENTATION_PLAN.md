# Implementation Plan - TDD Workflow

## Overview

This plan breaks down the implementation into small, testable increments following strict TDD (Test-Driven Development). Each task follows the Red-Green-Refactor cycle.

## TDD Workflow

For each feature:

1. **RED**: Write a failing test
2. **GREEN**: Write minimal code to make test pass
3. **REFACTOR**: Improve code while keeping tests green
4. **COMMIT**: Commit when tests pass
5. **REPEAT**: Move to next feature

## Phase 1: Foundation (Core Types & Infrastructure)

### 1.1 Project Setup
- [ ] Set up package structure
- [ ] Configure pytest
- [ ] Configure mypy (strict mode)
- [ ] Add basic dependencies

**Files**:
- `pyproject.toml` (already exists, may need updates)
- `src/anchor_modeling_tool/__init__.py`
- `tests/conftest.py`

**Time**: ~15 minutes

---

### 1.2 Core Immutable Types

#### Test 1: Create Metadata dataclass
**File**: `tests/unit/test_types_metadata.py`

```python
def test_metadata_default_values():
    """Metadata should have sensible defaults"""
    metadata = Metadata()
    assert metadata.identity == "int"
    assert metadata.temporalization == "uni"
    assert metadata.database_target == "SQLServer"

def test_metadata_immutable():
    """Metadata should be immutable"""
    metadata = Metadata()
    with pytest.raises(FrozenInstanceError):
        metadata.identity = "bigint"
```

**Implementation**: `src/anchor_modeling_tool/types/metadata.py`
- Define `Metadata` frozen dataclass with all 50+ fields

**Time**: ~30 minutes

---

#### Test 2: Create Schema element types
**File**: `tests/unit/test_types_schema.py`

```python
def test_knot_creation():
    """Create a simple knot"""
    knot = Knot(
        mnemonic="GEN",
        descriptor="Gender",
        identity="bit",
        data_range="varchar(42)"
    )
    assert knot.mnemonic == "GEN"
    assert knot.descriptor == "Gender"

def test_knot_immutable():
    """Knot should be immutable"""
    knot = Knot(...)
    with pytest.raises(FrozenInstanceError):
        knot.mnemonic = "SEX"

def test_anchor_with_attributes():
    """Anchor can contain multiple attributes"""
    attr1 = Attribute(mnemonic="NAM", descriptor="Name", data_range="varchar(42)")
    attr2 = Attribute(mnemonic="AGE", descriptor="Age", data_range="int")
    anchor = Anchor(
        mnemonic="PN",
        descriptor="Person",
        identity="int",
        attributes=frozenset([attr1, attr2])
    )
    assert len(anchor.attributes) == 2
    assert attr1 in anchor.attributes
```

**Implementation**: `src/anchor_modeling_tool/types/schema.py`
- Define: `Key`, `Attribute`, `Knot`, `Anchor`, `Role`, `Tie`, `Nexus`, `Schema`
- All frozen dataclasses

**Time**: ~45 minutes

---

### 1.3 Utility Functions

#### Test 3: Result type for error handling
**File**: `tests/unit/test_utils_result.py`

```python
def test_ok_result():
    """Ok result wraps success value"""
    result = Ok(42)
    assert result.value == 42

def test_err_result():
    """Err result wraps error"""
    result = Err("Something went wrong")
    assert result.error == "Something went wrong"

def test_map_result_ok():
    """Map transforms Ok value"""
    result = Ok(5)
    mapped = map_result(result, lambda x: x * 2)
    assert mapped == Ok(10)

def test_map_result_err():
    """Map preserves Err"""
    result = Err("error")
    mapped = map_result(result, lambda x: x * 2)
    assert mapped == Err("error")

def test_flat_map_result():
    """Flat map chains results"""
    def safe_divide(a: int, b: int) -> Result[int, str]:
        if b == 0:
            return Err("Division by zero")
        return Ok(a // b)

    result = flat_map_result(Ok(10), lambda x: safe_divide(x, 2))
    assert result == Ok(5)

    result = flat_map_result(Ok(10), lambda x: safe_divide(x, 0))
    assert isinstance(result, Err)
```

**Implementation**: `src/anchor_modeling_tool/utils/result.py`
- Define `Ok`, `Err`, `Result` type alias
- Implement `map_result`, `flat_map_result`

**Time**: ~20 minutes

---

#### Test 4: Function composition utilities
**File**: `tests/unit/test_utils_functional.py`

```python
def test_pipe():
    """Pipe applies functions left to right"""
    result = pipe(
        5,
        lambda x: x * 2,
        lambda x: x + 3,
        lambda x: x ** 2
    )
    assert result == 169  # ((5 * 2) + 3) ** 2 = 13 ** 2

def test_compose():
    """Compose creates right-to-left function"""
    f = compose(
        lambda x: x ** 2,
        lambda x: x + 3,
        lambda x: x * 2
    )
    assert f(5) == 169

def test_curry():
    """Curry transforms multi-arg function"""
    def add(a: int, b: int, c: int) -> int:
        return a + b + c

    curried = curry(add)
    assert curried(1)(2)(3) == 6
    assert curried(1, 2)(3) == 6
```

**Implementation**: `src/anchor_modeling_tool/utils/functional.py`
- Implement `pipe`, `compose`, `curry` (if needed)

**Time**: ~20 minutes

---

## Phase 2: JSON Parser (Simplest Format)

### 2.1 Parse Simple Knot

#### Test 5: Parse single knot from JSON
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_single_knot():
    """Parse a JSON manifest with one knot"""
    json_text = """
    {
      "schema": {
        "metadata": {
          "temporalization": "uni",
          "databaseTarget": "SQLServer"
        },
        "knot": {
          "GEN": {
            "mnemonic": "GEN",
            "descriptor": "Gender",
            "identity": "bit",
            "dataRange": "varchar(42)"
          }
        },
        "knots": ["GEN"]
      }
    }
    """

    result = parse_json(json_text)

    assert isinstance(result, Ok)
    schema = result.value
    assert len(schema.knots) == 1

    knot = next(iter(schema.knots))
    assert knot.mnemonic == "GEN"
    assert knot.descriptor == "Gender"
    assert knot.identity == "bit"
    assert knot.data_range == "varchar(42)"

def test_parse_json_invalid_format():
    """Parse invalid JSON returns error"""
    result = parse_json("{invalid json}")
    assert isinstance(result, Err)
    assert "JSON" in result.error
```

**Implementation**: `src/anchor_modeling_tool/parsers/json_parser.py`
- Implement `parse_json` for knots only
- Handle JSON parsing errors

**Time**: ~30 minutes

---

#### Test 6: Parse metadata from JSON
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_metadata():
    """Parse metadata configuration"""
    json_text = """
    {
      "schema": {
        "metadata": {
          "temporalization": "crt",
          "databaseTarget": "PostgreSQL",
          "identity": "bigint",
          "triggers": "false"
        },
        "knots": []
      }
    }
    """

    result = parse_json(json_text)
    assert isinstance(result, Ok)

    metadata = result.value.metadata
    assert metadata.temporalization == "crt"
    assert metadata.database_target == "PostgreSQL"
    assert metadata.identity == "bigint"
    assert metadata.triggers is False

def test_parse_metadata_defaults():
    """Missing metadata uses defaults"""
    json_text = """
    {
      "schema": {
        "knots": []
      }
    }
    """

    result = parse_json(json_text)
    assert isinstance(result, Ok)

    metadata = result.value.metadata
    assert metadata.temporalization == "uni"
    assert metadata.database_target == "SQLServer"
```

**Implementation**: Extend `parse_json` to handle metadata

**Time**: ~20 minutes

---

### 2.2 Parse Anchors and Attributes

#### Test 7: Parse simple anchor (no attributes)
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_simple_anchor():
    """Parse anchor without attributes"""
    json_text = """
    {
      "schema": {
        "metadata": {},
        "anchor": {
          "PN": {
            "mnemonic": "PN",
            "descriptor": "Person",
            "identity": "int"
          }
        },
        "anchors": ["PN"]
      }
    }
    """

    result = parse_json(json_text)
    assert isinstance(result, Ok)

    schema = result.value
    assert len(schema.anchors) == 1

    anchor = next(iter(schema.anchors))
    assert anchor.mnemonic == "PN"
    assert anchor.descriptor == "Person"
    assert anchor.identity == "int"
    assert len(anchor.attributes) == 0
```

**Implementation**: Extend `parse_json` for anchors

**Time**: ~15 minutes

---

#### Test 8: Parse anchor with static attribute
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_anchor_with_static_attribute():
    """Parse anchor with one static attribute"""
    json_text = """
    {
      "schema": {
        "metadata": {},
        "anchor": {
          "PN": {
            "mnemonic": "PN",
            "descriptor": "Person",
            "identity": "int",
            "attribute": {
              "SSN": {
                "mnemonic": "SSN",
                "descriptor": "SocialSecurityNumber",
                "dataRange": "varchar(11)"
              }
            },
            "attributes": ["SSN"]
          }
        },
        "anchors": ["PN"]
      }
    }
    """

    result = parse_json(json_text)
    schema = result.value
    anchor = next(iter(schema.anchors))

    assert len(anchor.attributes) == 1
    attr = next(iter(anchor.attributes))
    assert attr.mnemonic == "SSN"
    assert attr.descriptor == "SocialSecurityNumber"
    assert attr.data_range == "varchar(11)"
    assert attr.time_range is None
    assert attr.knot_range is None
```

**Implementation**: Extend parser for attributes

**Time**: ~20 minutes

---

#### Test 9: Parse historized attribute
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_historized_attribute():
    """Parse attribute with time range"""
    json_text = """
    {
      "schema": {
        "metadata": {},
        "anchor": {
          "AC": {
            "mnemonic": "AC",
            "descriptor": "Actor",
            "identity": "int",
            "attribute": {
              "NAM": {
                "mnemonic": "NAM",
                "descriptor": "Name",
                "timeRange": "datetime",
                "dataRange": "varchar(42)"
              }
            },
            "attributes": ["NAM"]
          }
        },
        "anchors": ["AC"]
      }
    }
    """

    result = parse_json(json_text)
    schema = result.value
    anchor = next(iter(schema.anchors))
    attr = next(iter(anchor.attributes))

    assert attr.time_range == "datetime"
    assert attr.data_range == "varchar(42)"
```

**Implementation**: Handle timeRange in parser

**Time**: ~10 minutes

---

#### Test 10: Parse knotted attribute
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_knotted_attribute():
    """Parse attribute referencing knot"""
    json_text = """
    {
      "schema": {
        "metadata": {},
        "knot": {
          "GEN": {
            "mnemonic": "GEN",
            "descriptor": "Gender",
            "identity": "bit",
            "dataRange": "varchar(42)"
          }
        },
        "knots": ["GEN"],
        "anchor": {
          "AC": {
            "mnemonic": "AC",
            "descriptor": "Actor",
            "identity": "int",
            "attribute": {
              "GEN": {
                "mnemonic": "GEN",
                "descriptor": "Gender",
                "knotRange": "GEN"
              }
            },
            "attributes": ["GEN"]
          }
        },
        "anchors": ["AC"]
      }
    }
    """

    result = parse_json(json_text)
    schema = result.value
    anchor = next(iter(schema.anchors))
    attr = next(iter(anchor.attributes))

    assert attr.knot_range == "GEN"
    assert attr.data_range is None
```

**Implementation**: Handle knotRange in parser

**Time**: ~10 minutes

---

### 2.3 Parse Ties

#### Test 11: Parse simple binary tie
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_simple_tie():
    """Parse tie with two anchor roles"""
    json_text = """
    {
      "schema": {
        "metadata": {},
        "anchor": {
          "AC": {"mnemonic": "AC", "descriptor": "Actor", "identity": "int"},
          "PN": {"mnemonic": "PN", "descriptor": "Person", "identity": "int"}
        },
        "anchors": ["AC", "PN"],
        "tie": {
          "AC_subset_PN_of": {
            "id": "AC_subset_PN_of",
            "anchorRole": {
              "AC_subset": {
                "role": "subset",
                "type": "AC",
                "identifier": "true"
              },
              "PN_of": {
                "role": "of",
                "type": "PN",
                "identifier": "true"
              }
            },
            "roles": ["AC_subset", "PN_of"]
          }
        },
        "ties": ["AC_subset_PN_of"]
      }
    }
    """

    result = parse_json(json_text)
    schema = result.value

    assert len(schema.ties) == 1
    tie = next(iter(schema.ties))
    assert tie.id == "AC_subset_PN_of"
    assert len(tie.roles) == 2

    roles = sorted(tie.roles, key=lambda r: r.role)
    assert roles[0].role == "of"
    assert roles[0].type == "PN"
    assert roles[0].identifier is True
```

**Implementation**: Extend parser for ties

**Time**: ~30 minutes

---

#### Test 12: Parse historized tie with knot
**File**: `tests/unit/test_parsers_json.py`

```python
def test_parse_tie_with_knot_role():
    """Parse tie with anchor and knot roles"""
    json_text = """
    {
      "schema": {
        "metadata": {},
        "knot": {
          "ONG": {"mnemonic": "ONG", "descriptor": "Ongoing",
                  "identity": "tinyint", "dataRange": "varchar(3)"}
        },
        "knots": ["ONG"],
        "anchor": {
          "AC": {"mnemonic": "AC", "descriptor": "Actor", "identity": "int"}
        },
        "anchors": ["AC"],
        "tie": {
          "AC_exclusive_AC_with_ONG_currently": {
            "id": "AC_exclusive_AC_with_ONG_currently",
            "timeRange": "datetime",
            "anchorRole": {
              "AC_exclusive": {"role": "exclusive", "type": "AC", "identifier": "false"},
              "AC_with": {"role": "with", "type": "AC", "identifier": "false"}
            },
            "knotRole": {
              "ONG_currently": {"role": "currently", "type": "ONG", "identifier": "false"}
            },
            "roles": ["AC_exclusive", "AC_with", "ONG_currently"]
          }
        },
        "ties": ["AC_exclusive_AC_with_ONG_currently"]
      }
    }
    """

    result = parse_json(json_text)
    tie = next(iter(result.value.ties))

    assert tie.time_range == "datetime"
    assert len(tie.roles) == 3
```

**Implementation**: Handle knotRole and timeRange in ties

**Time**: ~20 minutes

---

### 2.4 Parse Complete Schema

#### Test 13: Parse example.json fixture
**File**: `tests/integration/test_parse_example_json.py`

```python
def test_parse_example_json_fixture():
    """Parse the complete example.json fixture"""
    with open("tests/fixtures/example.json") as f:
        json_text = f.read()

    result = parse_json(json_text)
    assert isinstance(result, Ok)

    schema = result.value

    # Verify counts
    assert len(schema.knots) == 6  # PAT, GEN, PLV, UTL, ONG, RAT
    assert len(schema.anchors) == 5  # PE, PN, ST, AC, PR
    assert len(schema.ties) == 9

    # Spot check metadata
    assert schema.metadata.temporalization == "uni"
    assert schema.metadata.database_target == "SQLServer"

    # Spot check a knot
    gen_knot = next(k for k in schema.knots if k.mnemonic == "GEN")
    assert gen_knot.descriptor == "Gender"
    assert gen_knot.identity == "bit"

    # Spot check an anchor with attributes
    ac_anchor = next(a for a in schema.anchors if a.mnemonic == "AC")
    assert ac_anchor.descriptor == "Actor"
    assert len(ac_anchor.attributes) == 3  # NAM, GEN, PLV
```

**Implementation**: Ensure parser handles all constructs

**Time**: ~30 minutes

---

## Phase 3: Naming Convention

### 3.1 Table Naming

#### Test 14: Generate knot table name
**File**: `tests/unit/test_naming_convention.py`

```python
def test_knot_table_name_sqlserver():
    """Generate table name for knot (SQL Server)"""
    knot = Knot(
        mnemonic="GEN",
        descriptor="Gender",
        identity="bit",
        data_range="varchar(42)"
    )
    metadata = Metadata(
        database_target="SQLServer",
        encapsulation="dbo"
    )

    table_name = generate_table_name(knot, metadata)

    assert table_name.schema == "dbo"
    assert table_name.name == "GEN_Gender"
    assert table_name.full == "[dbo].[GEN_Gender]"

def test_anchor_table_name():
    """Generate table name for anchor"""
    anchor = Anchor(
        mnemonic="PN",
        descriptor="Person",
        identity="int"
    )
    metadata = Metadata(encapsulation="dbo")

    table_name = generate_table_name(anchor, metadata)
    assert table_name.name == "PN_Person"
```

**Implementation**: `src/anchor_modeling_tool/naming/convention.py`
- Implement `generate_table_name` for knots and anchors

**Time**: ~25 minutes

---

#### Test 15: Generate attribute table name
**File**: `tests/unit/test_naming_convention.py`

```python
def test_attribute_table_name():
    """Generate table name for attribute"""
    anchor = Anchor(
        mnemonic="AC",
        descriptor="Actor",
        identity="int"
    )
    attribute = Attribute(
        mnemonic="NAM",
        descriptor="Name",
        data_range="varchar(42)"
    )
    metadata = Metadata(encapsulation="dbo")

    table_name = generate_attribute_table_name(anchor, attribute, metadata)
    assert table_name.name == "AC_NAM_Actor_Name"
    assert table_name.full == "[dbo].[AC_NAM_Actor_Name]"
```

**Implementation**: Extend naming for attributes

**Time**: ~15 minutes

---

#### Test 16: Generate tie table name
**File**: `tests/unit/test_naming_convention.py`

```python
def test_tie_table_name():
    """Generate table name for tie"""
    tie = Tie(
        id="AC_subset_PN_of",
        roles=frozenset([
            Role(role="subset", type="AC", identifier=True),
            Role(role="of", type="PN", identifier=True)
        ])
    )
    metadata = Metadata(encapsulation="dbo")

    table_name = generate_tie_table_name(tie, metadata)
    # Note: Should concatenate role types
    assert table_name.name == "AC_PN"
```

**Implementation**: Implement tie naming logic

**Time**: ~20 minutes

---

### 3.2 Column Naming

#### Test 17: Generate column names
**File**: `tests/unit/test_naming_convention.py`

```python
def test_knot_column_names():
    """Generate column names for knot"""
    knot = Knot(
        mnemonic="GEN",
        descriptor="Gender",
        identity="bit",
        data_range="varchar(42)"
    )
    metadata = Metadata()

    columns = generate_knot_columns(knot, metadata)

    assert columns.id_column.name == "GEN_ID"
    assert columns.value_column.name == "GEN_Gender"
    assert columns.metadata_column.name == "Metadata_GEN"

def test_attribute_column_names():
    """Generate column names for attribute"""
    anchor = Anchor(mnemonic="AC", descriptor="Actor", identity="int")
    attribute = Attribute(
        mnemonic="NAM",
        descriptor="Name",
        time_range="datetime",
        data_range="varchar(42)"
    )
    metadata = Metadata()

    columns = generate_attribute_columns(anchor, attribute, metadata)

    assert columns.anchor_id_column.name == "AC_NAM_AC_ID"
    assert columns.value_column.name == "AC_NAM_Name"
    assert columns.changed_at_column.name == "AC_NAM_ChangedAt"
    assert columns.metadata_column.name == "Metadata_AC_NAM"
```

**Implementation**: Implement column naming functions

**Time**: ~30 minutes

---

### 3.3 Apply Naming to Entire Schema

#### Test 18: Apply naming to create NamedSchema
**File**: `tests/unit/test_naming_convention.py`

```python
def test_apply_naming_to_schema():
    """Apply naming convention to entire schema"""
    schema = Schema(
        metadata=Metadata(),
        knots=frozenset([
            Knot(mnemonic="GEN", descriptor="Gender",
                 identity="bit", data_range="varchar(42)")
        ]),
        anchors=frozenset([
            Anchor(mnemonic="PN", descriptor="Person", identity="int")
        ])
    )

    named_schema = apply_naming(schema)

    assert len(named_schema.knots) == 1
    named_knot = next(iter(named_schema.knots))
    assert named_knot.table_name.name == "GEN_Gender"
    assert named_knot.id_column.name == "GEN_ID"

    assert len(named_schema.anchors) == 1
    named_anchor = next(iter(named_schema.anchors))
    assert named_anchor.table_name.name == "PN_Person"
```

**Implementation**: Implement `apply_naming` function
- Create NamedKnot, NamedAnchor, etc. types in `types/named.py`
- Implement full naming pipeline

**Time**: ~45 minutes

---

## Phase 4: SQL Generation - Knots (SQL Server Uni-temporal)

### 4.1 Simple Knot Table

#### Test 19: Generate simple knot CREATE TABLE
**File**: `tests/unit/test_generators_knots.py`

```python
def test_generate_simple_knot_table():
    """Generate CREATE TABLE for simple knot"""
    named_knot = NamedKnot(
        knot=Knot(
            mnemonic="GEN",
            descriptor="Gender",
            identity="bit",
            data_range="varchar(42)"
        ),
        table_name=TableName(schema="dbo", name="GEN_Gender",
                            full="[dbo].[GEN_Gender]"),
        id_column=ColumnName(name="GEN_ID", business_name="Gender"),
        value_column=ColumnName(name="GEN_Gender", business_name="Gender"),
        metadata_column=ColumnName(name="Metadata_GEN", business_name="Metadata")
    )
    metadata = Metadata()

    statement = generate_knot_table(named_knot, metadata)

    expected = """CREATE TABLE [dbo].[GEN_Gender] (
    GEN_ID bit not null,
    GEN_Gender varchar(42) not null,
    Metadata_GEN int not null,
    constraint pkGEN_Gender primary key (GEN_ID asc),
    constraint uqGEN_Gender unique (GEN_Gender)
)"""

    assert normalize_whitespace(statement.sql) == normalize_whitespace(expected)
```

**Implementation**: `src/anchor_modeling_tool/generators/knots.py`
- Implement `generate_knot_table` for SQL Server

**Time**: ~30 minutes

---

#### Test 20: Generate knot with checksum
**File**: `tests/unit/test_generators_knots.py`

```python
def test_generate_knot_with_checksum():
    """Generate knot table with checksum column"""
    knot = Knot(
        mnemonic="PLV",
        descriptor="ProfessionalLevel",
        identity="tinyint",
        data_range="varchar(max)",
        metadata={"checksum": "true"}
    )
    # ... create named_knot
    metadata = Metadata(checksum=True)

    statement = generate_knot_table(named_knot, metadata)

    assert "PLV_Checksum" in statement.sql
    assert "varchar(max)" in statement.sql
```

**Implementation**: Extend generator to handle checksum

**Time**: ~20 minutes

---

### 4.2 Knot Section

#### Test 21: Generate knots section
**File**: `tests/unit/test_generators_knots.py`

```python
def test_generate_knots_section():
    """Generate complete knots section"""
    named_schema = NamedSchema(
        schema=Schema(
            metadata=Metadata(),
            knots=frozenset([...])  # multiple knots
        ),
        knots=frozenset([...])  # named knots
    )

    section = generate_knots_section(named_schema)

    assert section.name == "KNOTS"
    assert len(section.statements) == len(named_schema.knots)

    # Check each statement is valid SQL
    for stmt in section.statements:
        assert "CREATE TABLE" in stmt.sql
        assert "constraint pk" in stmt.sql
```

**Implementation**: Implement `generate_knots_section`

**Time**: ~20 minutes

---

## Phase 5: SQL Generation - Anchors

### 5.1 Simple Anchor Table

#### Test 22: Generate anchor with identity
**File**: `tests/unit/test_generators_anchors.py`

```python
def test_generate_anchor_with_identity():
    """Generate anchor table with auto-increment identity"""
    named_anchor = NamedAnchor(
        anchor=Anchor(
            mnemonic="PN",
            descriptor="Person",
            identity="int",
            metadata={"generator": "true"}
        ),
        table_name=TableName(schema="dbo", name="PN_Person",
                            full="[dbo].[PN_Person]"),
        id_column=ColumnName(name="PN_ID", business_name="Person")
    )
    metadata = Metadata()

    statement = generate_anchor_table(named_anchor, metadata)

    expected = """CREATE TABLE [dbo].[PN_Person] (
    PN_ID int identity(1,1) not null,
    constraint pkPN_Person primary key (PN_ID asc)
)"""

    assert normalize_whitespace(statement.sql) == normalize_whitespace(expected)

def test_generate_anchor_without_generator():
    """Generate anchor table without auto-increment"""
    anchor = Anchor(
        mnemonic="KN",
        descriptor="Knot",
        identity="int",
        metadata={"generator": "false"}
    )
    # ... create named_anchor

    statement = generate_anchor_table(named_anchor, metadata)

    # Should NOT have identity(1,1)
    assert "identity" not in statement.sql.lower()
    assert "KN_ID int not null" in statement.sql
```

**Implementation**: `src/anchor_modeling_tool/generators/anchors.py`

**Time**: ~25 minutes

---

## Phase 6: SQL Generation - Attributes

### 6.1 Static Attribute

#### Test 23: Generate static attribute table
**File**: `tests/unit/test_generators_attributes.py`

```python
def test_generate_static_attribute():
    """Generate static attribute (no timeRange)"""
    anchor = Anchor(mnemonic="PE", descriptor="Performance", identity="int")
    attribute = Attribute(
        mnemonic="AUD",
        descriptor="Audience",
        data_range="int"
    )
    # ... create named versions

    statement = generate_attribute_table(named_anchor, named_attribute, metadata)

    expected = """CREATE TABLE [dbo].[PE_AUD_Performance_Audience] (
    PE_AUD_PE_ID int not null,
    PE_AUD_Audience int not null,
    Metadata_PE_AUD int not null,
    constraint fkPE_AUD_Performance_Audience foreign key (
        PE_AUD_PE_ID
    ) references [dbo].[PE_Performance](PE_ID),
    constraint pkPE_AUD_Performance_Audience primary key (
        PE_AUD_PE_ID asc
    )
)"""

    assert normalize_whitespace(statement.sql) == normalize_whitespace(expected)
```

**Implementation**: `src/anchor_modeling_tool/generators/attributes.py`

**Time**: ~35 minutes

---

### 6.2 Historized Attribute

#### Test 24: Generate historized attribute table
**File**: `tests/unit/test_generators_attributes.py`

```python
def test_generate_historized_attribute():
    """Generate historized attribute (with timeRange)"""
    attribute = Attribute(
        mnemonic="NAM",
        descriptor="Name",
        time_range="datetime",
        data_range="varchar(42)"
    )
    # ... setup

    statement = generate_attribute_table(named_anchor, named_attribute, metadata)

    # Should have ChangedAt column
    assert "AC_NAM_ChangedAt datetime not null" in statement.sql

    # Primary key should include ChangedAt DESC
    assert "primary key (\n        AC_NAM_AC_ID asc,\n        AC_NAM_ChangedAt desc\n    )" in statement.sql
```

**Implementation**: Extend generator for historized attributes

**Time**: ~20 minutes

---

### 6.3 Knotted Attribute

#### Test 25: Generate knotted attribute table
**File**: `tests/unit/test_generators_attributes.py`

```python
def test_generate_knotted_attribute():
    """Generate attribute referencing knot"""
    attribute = Attribute(
        mnemonic="GEN",
        descriptor="Gender",
        knot_range="GEN"
    )
    # ... setup with knot in schema

    statement = generate_attribute_table(named_anchor, named_attribute, metadata)

    # Should have FK column to knot (not value column)
    assert "AC_GEN_GEN_Gender bit not null" in statement.sql

    # Should have FK constraint to knot table
    assert "references [dbo].[GEN_Gender](GEN_ID)" in statement.sql
```

**Implementation**: Handle knot references

**Time**: ~25 minutes

---

### 6.4 Historized Knotted Attribute

#### Test 26: Generate historized knotted attribute
**File**: `tests/unit/test_generators_attributes.py`

```python
def test_generate_historized_knotted_attribute():
    """Generate historized attribute with knot reference"""
    attribute = Attribute(
        mnemonic="PLV",
        descriptor="ProfessionalLevel",
        time_range="datetime",
        knot_range="PLV"
    )
    # ... setup

    statement = generate_attribute_table(named_anchor, named_attribute, metadata)

    # Should have both knot FK and ChangedAt
    assert "AC_PLV_PLV_ProfessionalLevel tinyint not null" in statement.sql
    assert "AC_PLV_ChangedAt datetime not null" in statement.sql

    # PK should include both ID and ChangedAt
    assert "primary key (\n        AC_PLV_AC_ID asc,\n        AC_PLV_ChangedAt desc\n    )" in statement.sql
```

**Implementation**: Combine historization + knot reference

**Time**: ~15 minutes

---

## Phase 7: SQL Generation - Ties

### 7.1 Static Binary Tie

#### Test 27: Generate static tie
**File**: `tests/unit/test_generators_ties.py`

```python
def test_generate_static_binary_tie():
    """Generate static tie between two anchors"""
    tie = Tie(
        id="AC_subset_PN_of",
        roles=frozenset([
            Role(role="subset", type="AC", identifier=True),
            Role(role="of", type="PN", identifier=True)
        ])
    )
    # ... setup named versions

    statement = generate_tie_table(named_tie, metadata)

    expected = """CREATE TABLE [dbo].[AC_PN] (
    AC_subset_AC_ID int not null,
    PN_of_PN_ID int not null,
    Metadata_AC_PN int not null,
    constraint fkAC_subset_AC_PN foreign key (
        AC_subset_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fkPN_of_AC_PN foreign key (
        PN_of_PN_ID
    ) references [dbo].[PN_Person](PN_ID),
    constraint pkAC_PN primary key (
        AC_subset_AC_ID asc,
        PN_of_PN_ID asc
    )
)"""

    assert normalize_whitespace(statement.sql) == normalize_whitespace(expected)
```

**Implementation**: `src/anchor_modeling_tool/generators/ties.py`

**Time**: ~40 minutes

---

### 7.2 Historized Tie

#### Test 28: Generate historized tie
**File**: `tests/unit/test_generators_ties.py`

```python
def test_generate_historized_tie():
    """Generate tie with time_range"""
    tie = Tie(
        id="ST_at_PR_isPlaying",
        time_range="datetime",
        roles=frozenset([
            Role(role="at", type="ST", identifier=True),
            Role(role="isPlaying", type="PR", identifier=True)
        ])
    )
    # ... setup

    statement = generate_tie_table(named_tie, metadata)

    # Should have ChangedAt column
    assert "ST_PR_ChangedAt datetime not null" in statement.sql

    # PK should include ChangedAt DESC
    assert "primary key (\n        ST_at_ST_ID asc,\n        PR_isPlaying_PR_ID asc,\n        ST_PR_ChangedAt desc\n    )" in statement.sql
```

**Implementation**: Extend for historized ties

**Time**: ~20 minutes

---

### 7.3 Tie with Knot Role

#### Test 29: Generate tie with knot
**File**: `tests/unit/test_generators_ties.py`

```python
def test_generate_tie_with_knot_role():
    """Generate tie including knot role"""
    tie = Tie(
        id="AC_parent_AC_child_PAT_having",
        roles=frozenset([
            Role(role="parent", type="AC", identifier=True),
            Role(role="child", type="AC", identifier=True),
            Role(role="having", type="PAT", identifier=True)  # knot
        ])
    )
    # ... setup

    statement = generate_tie_table(named_tie, metadata)

    # Should have FK to knot
    assert "PAT_having_PAT_ID tinyint not null" in statement.sql
    assert "references [dbo].[PAT_ParentalType](PAT_ID)" in statement.sql

    # PK should include knot role
    assert "PAT_having_PAT_ID asc" in statement.sql
```

**Implementation**: Handle knot roles in ties

**Time**: ~20 minutes

---

## Phase 8: Integration & End-to-End Tests

### 8.1 End-to-End: Simple Schema

#### Test 30: Generate SQL for minimal schema
**File**: `tests/integration/test_e2e_simple.py`

```python
def test_e2e_simple_schema():
    """End-to-end: parse → name → generate → format"""
    json_text = """
    {
      "schema": {
        "metadata": {"temporalization": "uni", "databaseTarget": "SQLServer"},
        "knot": {
          "GEN": {
            "mnemonic": "GEN",
            "descriptor": "Gender",
            "identity": "bit",
            "dataRange": "varchar(42)"
          }
        },
        "knots": ["GEN"],
        "anchor": {
          "PN": {
            "mnemonic": "PN",
            "descriptor": "Person",
            "identity": "int",
            "attribute": {
              "GEN": {
                "mnemonic": "GEN",
                "descriptor": "Gender",
                "knotRange": "GEN"
              }
            },
            "attributes": ["GEN"]
          }
        },
        "anchors": ["PN"]
      }
    }
    """

    # Parse
    parse_result = parse_json(json_text)
    assert isinstance(parse_result, Ok)
    schema = parse_result.value

    # Name
    named_schema = apply_naming(schema)

    # Generate
    gen_result = generate_sql(named_schema, GenerationConfig())
    assert isinstance(gen_result, Ok)
    script = gen_result.value

    # Format
    sql_text = format_sql(script)

    # Verify output contains expected tables
    assert "CREATE TABLE [dbo].[GEN_Gender]" in sql_text
    assert "CREATE TABLE [dbo].[PN_Person]" in sql_text
    assert "CREATE TABLE [dbo].[PN_GEN_Person_Gender]" in sql_text

    # Verify structure
    assert "constraint pk" in sql_text
    assert "constraint fk" in sql_text
```

**Implementation**:
- `src/anchor_modeling_tool/generators/pipeline.py` (orchestration)
- `src/anchor_modeling_tool/formatters/sql_formatter.py`

**Time**: ~60 minutes

---

### 8.2 End-to-End: Complete Example

#### Test 31: Generate SQL matching example.sql
**File**: `tests/integration/test_e2e_example.py`

```python
def test_e2e_example_json_to_sql():
    """End-to-end test with example.json fixture"""
    # Load input
    with open("tests/fixtures/example.json") as f:
        json_text = f.read()

    # Load expected output
    with open("tests/fixtures/example.sql") as f:
        expected_sql = f.read()

    # Generate SQL
    result = manifest_to_sql(
        json_text,
        format="json",
        config=GenerationConfig(
            database_target="SQLServer",
            temporalization="uni"
        )
    )

    assert isinstance(result, Ok)
    generated_sql = result.value

    # Compare structure (not exact match due to formatting)
    expected_tables = extract_table_names(expected_sql)
    generated_tables = extract_table_names(generated_sql)

    assert expected_tables == generated_tables

    # Spot check a few constructs
    assert "[dbo].[GEN_Gender]" in generated_sql
    assert "[dbo].[AC_NAM_Actor_Name]" in generated_sql
    assert "AC_NAM_ChangedAt datetime not null" in generated_sql
```

**Implementation**: Ensure all pieces work together

**Time**: ~45 minutes

---

## Iteration Strategy

After Phase 8, iterate to add:

**Phase 9**: YAML and XML parsers (similar to JSON)
**Phase 10**: Schema validation
**Phase 11**: Triggers, views, keys (advanced SQL features)
**Phase 12**: PostgreSQL support
**Phase 13**: CRT temporalization
**Phase 14**: Nexus support
**Phase 15**: Other databases (Oracle, Snowflake, Vertica)

Each phase follows same TDD workflow:
1. Write failing tests
2. Implement minimal code
3. Refactor
4. Commit

## Daily Workflow

**Start of day**:
1. Review todo list and plan
2. Pick next test to write
3. Write failing test (RED)

**During development**:
1. Implement minimal code to pass test (GREEN)
2. Refactor while keeping tests green
3. Commit when all tests pass
4. Repeat

**End of day**:
1. Ensure all tests pass
2. Update progress in plan
3. Identify next tests for tomorrow

## Estimated Timeline

- **Phase 1-2**: Foundation + JSON parser: ~6 hours
- **Phase 3**: Naming convention: ~3 hours
- **Phase 4-7**: SQL generation (knots, anchors, attributes, ties): ~8 hours
- **Phase 8**: Integration tests: ~3 hours
- **Phase 9-10**: YAML/XML parsers + validation: ~4 hours
- **Phase 11**: Advanced SQL features: ~8 hours
- **Phase 12-15**: Additional databases/temporal models: ~12 hours

**Total**: ~44 hours of focused TDD development

## Success Metrics

- [ ] All tests passing (green)
- [ ] >95% code coverage
- [ ] mypy --strict passes (100% type coverage)
- [ ] Output matches original implementation for SQL Server uni-temporal
- [ ] All functions are pure
- [ ] All data structures immutable
- [ ] No TODOs or FIXMEs in code
- [ ] All public functions documented

## Notes

- Commit after each test passes (GREEN phase)
- Never skip tests ("I'll test it later" = never)
- Keep functions small (<20 lines)
- Keep test files small (<500 lines, split if needed)
- Use descriptive test names
- One assertion concept per test (but multiple asserts OK if testing same thing)
