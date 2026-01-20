# Anchor Modeling Tool - Functional Architecture

## Overview

This document describes the functional programming architecture for the Anchor Modeling Tool, which converts anchor model manifests (XML/JSON/YAML) to SQL DDL scripts for multiple database platforms.

## Design Principles

1. **Pure Functions**: All transformation logic implemented as pure functions with no side effects
2. **Immutable Data**: All data structures are immutable; transformations create new structures
3. **Composition**: Complex operations built from composing simple functions
4. **Type Safety**: Leverage Python type hints and mypy for compile-time verification
5. **Test-Driven Development**: Write failing tests first, implement until passing, then refactor

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    CLI / API Layer                          │
│              (IO boundary - not pure)                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Manifest Parser                           │
│     parse_xml / parse_json / parse_yaml                     │
│              → Schema (immutable)                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                Schema Normalization                         │
│    Normalize all formats to canonical Schema structure      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 Schema Validation                           │
│    validate_schema: Schema → Result[Schema, Errors]        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               Naming Convention Layer                       │
│    apply_naming: Schema → NamedSchema                       │
│    (attaches computed names to all elements)                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              SQL Generation Pipeline                        │
│   generate_sql: NamedSchema → Config → SQL                 │
│                                                             │
│   Composed of generator functions:                         │
│   • generate_knots                                          │
│   • generate_anchors                                        │
│   • generate_attributes                                     │
│   • generate_ties                                           │
│   • generate_nexuses                                        │
│   • generate_keys                                           │
│   • generate_triggers                                       │
│   • generate_views                                          │
│   • generate_tracking                                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  SQL Formatting                             │
│    format_sql: SQL → str                                    │
│    (pretty-print, comments, sections)                       │
└─────────────────────────────────────────────────────────────┘
```

## Core Data Types

### Schema Types (Immutable)

All types are implemented using `@dataclass(frozen=True)` for immutability.

```python
from dataclasses import dataclass
from typing import Literal, Optional, Dict, List, FrozenSet

@dataclass(frozen=True)
class Metadata:
    """Configuration metadata for SQL generation"""
    # Identity & Metadata
    identity: str = "int"
    identity_suffix: str = "ID"
    metadata_prefix: str = "Metadata"
    metadata_type: str = "int"
    metadata_usage: bool = True

    # Temporalization
    temporalization: Literal["uni", "crt", "bi"] = "uni"
    changing_range: str = "datetime"
    changing_suffix: str = "ChangedAt"
    chronon: str = "datetime2(7)"
    now: str = "sysdatetime()"

    # Positor (source tracking)
    posit_generator: bool = True
    positing_range: str = "datetime"
    positing_suffix: str = "PositedAt"
    positor_range: str = "tinyint"
    positor_suffix: str = "Positor"

    # Reliability
    reliability_range: str = "decimal(5,2)"
    reliability_suffix: str = "Reliability"
    default_reliability: str = "1"
    delete_reliability: str = "0"

    # Features
    equivalence: bool = False
    checksum: bool = False
    encryption: str = ""
    partitioning: bool = False
    triggers: bool = True
    business_views: bool = False
    deletability: bool = False
    idempotency: bool = False
    restatability: bool = True
    assertiveness: bool = True

    # Database
    database_target: Literal["SQLServer", "PostgreSQL", "Oracle", "Snowflake", "Vertica"] = "SQLServer"
    encapsulation: str = "dbo"
    naming: Literal["improved", "legacy"] = "improved"

    # ... all 50+ configuration options

@dataclass(frozen=True)
class Key:
    """Natural key component"""
    stop: int
    route: str  # "1st", "2nd", "3rd", etc.
    of: str  # anchor mnemonic
    branch: int

@dataclass(frozen=True)
class Attribute:
    """Attribute of an anchor or nexus"""
    mnemonic: str
    descriptor: str
    data_range: Optional[str] = None
    knot_range: Optional[str] = None
    time_range: Optional[str] = None
    keys: FrozenSet[Key] = frozenset()
    metadata: Optional[Dict[str, str]] = None

@dataclass(frozen=True)
class Knot:
    """Immutable reference data"""
    mnemonic: str
    descriptor: str
    identity: str
    data_range: str
    metadata: Optional[Dict[str, str]] = None

@dataclass(frozen=True)
class Anchor:
    """Entity identity"""
    mnemonic: str
    descriptor: str
    identity: str
    attributes: FrozenSet[Attribute] = frozenset()
    metadata: Optional[Dict[str, str]] = None

@dataclass(frozen=True)
class Role:
    """Role in a tie or nexus"""
    role: str
    type: str  # mnemonic of anchor/knot/nexus
    identifier: bool
    keys: FrozenSet[Key] = frozenset()

@dataclass(frozen=True)
class Tie:
    """Relationship between anchors/knots/nexuses"""
    id: str
    roles: FrozenSet[Role]
    time_range: Optional[str] = None
    metadata: Optional[Dict[str, str]] = None

@dataclass(frozen=True)
class Nexus:
    """Relationship as a first-class entity"""
    mnemonic: str
    descriptor: str
    identity: str
    attributes: FrozenSet[Attribute] = frozenset()
    roles: FrozenSet[Role] = frozenset()
    metadata: Optional[Dict[str, str]] = None

@dataclass(frozen=True)
class Schema:
    """Complete anchor model schema"""
    metadata: Metadata
    knots: FrozenSet[Knot] = frozenset()
    anchors: FrozenSet[Anchor] = frozenset()
    ties: FrozenSet[Tie] = frozenset()
    nexuses: FrozenSet[Nexus] = frozenset()
```

### Named Schema Types

After naming convention is applied:

```python
@dataclass(frozen=True)
class TableName:
    """Computed table name"""
    schema: str  # e.g., "dbo"
    name: str    # e.g., "PAT_ParentalType"
    full: str    # e.g., "[dbo].[PAT_ParentalType]"

@dataclass(frozen=True)
class ColumnName:
    """Computed column name"""
    name: str           # e.g., "PAT_ID"
    business_name: str  # e.g., "ParentalType"

@dataclass(frozen=True)
class NamedKnot:
    """Knot with computed names"""
    knot: Knot
    table_name: TableName
    id_column: ColumnName
    value_column: ColumnName
    metadata_column: Optional[ColumnName]

# Similar NamedAnchor, NamedAttribute, NamedTie, etc.

@dataclass(frozen=True)
class NamedSchema:
    """Schema with all names computed"""
    schema: Schema
    knots: FrozenSet[NamedKnot]
    anchors: FrozenSet[NamedAnchor]
    ties: FrozenSet[NamedTie]
    nexuses: FrozenSet[NamedNexus]
```

### SQL Types

```python
@dataclass(frozen=True)
class SQLStatement:
    """Single SQL statement"""
    sql: str
    comment: Optional[str] = None

@dataclass(frozen=True)
class SQLSection:
    """Section of SQL (e.g., "KNOTS", "ANCHORS")"""
    name: str
    statements: tuple[SQLStatement, ...]

@dataclass(frozen=True)
class SQLScript:
    """Complete SQL script"""
    sections: tuple[SQLSection, ...]

    def to_string(self) -> str:
        """Render to SQL text"""
        ...
```

## Functional Module Organization

```
src/anchor_modeling_tool/
├── __init__.py
├── types/
│   ├── __init__.py
│   ├── schema.py           # Schema, Knot, Anchor, Attribute, Tie, Nexus
│   ├── metadata.py         # Metadata configuration
│   ├── named.py            # NamedSchema, NamedKnot, etc.
│   └── sql.py              # SQLStatement, SQLSection, SQLScript
├── parsers/
│   ├── __init__.py
│   ├── xml_parser.py       # parse_xml: str → Schema
│   ├── json_parser.py      # parse_json: str → Schema
│   └── yaml_parser.py      # parse_yaml: str → Schema
├── validation/
│   ├── __init__.py
│   └── schema_validator.py # validate_schema: Schema → Result[Schema, Errors]
├── naming/
│   ├── __init__.py
│   ├── convention.py       # apply_naming: Schema → NamedSchema
│   └── database/
│       ├── sqlserver.py    # SQL Server naming rules
│       ├── postgresql.py   # PostgreSQL naming rules
│       └── ...
├── generators/
│   ├── __init__.py
│   ├── pipeline.py         # generate_sql: NamedSchema → Config → SQLScript
│   ├── knots.py            # generate_knots: NamedSchema → Config → SQLSection
│   ├── anchors.py          # generate_anchors: ...
│   ├── attributes.py       # generate_attributes: ...
│   ├── ties.py             # generate_ties: ...
│   ├── nexuses.py          # generate_nexuses: ...
│   ├── keys.py             # generate_keys: ...
│   ├── triggers.py         # generate_triggers: ...
│   ├── views.py            # generate_views: ...
│   └── database/
│       ├── sqlserver/
│       │   ├── uni/        # Uni-temporal SQL Server generators
│       │   ├── crt/        # CRT SQL Server generators
│       │   └── bi/         # Bi-temporal SQL Server generators
│       ├── postgresql/
│       │   ├── uni/
│       │   └── crt/
│       └── ...
├── formatters/
│   ├── __init__.py
│   └── sql_formatter.py    # format_sql: SQLScript → str
└── utils/
    ├── __init__.py
    ├── result.py           # Result[T, E] type for error handling
    └── functional.py       # Utility functions: pipe, compose, etc.
```

## Key Functional Patterns

### 1. Pipeline Composition

```python
from typing import Callable, TypeVar

A = TypeVar('A')
B = TypeVar('B')
C = TypeVar('C')

def pipe(value: A, *funcs: Callable) -> Any:
    """Left-to-right function composition"""
    result = value
    for func in funcs:
        result = func(result)
    return result

def compose(*funcs: Callable) -> Callable:
    """Right-to-left function composition"""
    def composed(value):
        result = value
        for func in reversed(funcs):
            result = func(result)
        return result
    return composed

# Usage:
sql = pipe(
    manifest_text,
    parse_json,
    validate_schema,
    apply_naming,
    lambda schema: generate_sql(schema, config),
    format_sql
)
```

### 2. Result Type for Error Handling

```python
from typing import TypeVar, Generic, Union
from dataclasses import dataclass

T = TypeVar('T')
E = TypeVar('E')

@dataclass(frozen=True)
class Ok(Generic[T]):
    value: T

@dataclass(frozen=True)
class Err(Generic[E]):
    error: E

Result = Union[Ok[T], Err[E]]

def map_result(result: Result[T, E], func: Callable[[T], U]) -> Result[U, E]:
    """Map over Ok value"""
    match result:
        case Ok(value):
            return Ok(func(value))
        case Err(error):
            return Err(error)

def flat_map_result(result: Result[T, E], func: Callable[[T], Result[U, E]]) -> Result[U, E]:
    """Flat map (bind) for Result"""
    match result:
        case Ok(value):
            return func(value)
        case Err(error):
            return Err(error)
```

### 3. Immutable Updates

```python
from dataclasses import replace

def add_attribute_to_anchor(anchor: Anchor, attribute: Attribute) -> Anchor:
    """Add attribute to anchor (returns new anchor)"""
    return replace(
        anchor,
        attributes=anchor.attributes | {attribute}
    )
```

### 4. Higher-Order Functions for SQL Generation

```python
def generate_section(
    name: str,
    items: Iterable[T],
    generator: Callable[[T, Metadata], SQLStatement]
) -> Callable[[Metadata], SQLSection]:
    """Higher-order function to create section generators"""
    def section_generator(metadata: Metadata) -> SQLSection:
        statements = tuple(generator(item, metadata) for item in items)
        return SQLSection(name=name, statements=statements)
    return section_generator

# Usage:
knots_section = generate_section(
    "KNOTS",
    schema.knots,
    generate_knot_table
)(metadata)
```

## TDD Workflow

### Phase 1: Red (Write Failing Test)

```python
# tests/test_knot_generation.py
def test_generate_simple_knot_table_sqlserver_uni():
    """Test generating a simple knot table for SQL Server uni-temporal"""
    # Arrange
    knot = Knot(
        mnemonic="GEN",
        descriptor="Gender",
        identity="bit",
        data_range="varchar(42)"
    )
    metadata = Metadata(
        database_target="SQLServer",
        temporalization="uni",
        encapsulation="dbo"
    )

    # Act
    result = generate_knot_table(knot, metadata)

    # Assert
    expected_sql = """
CREATE TABLE [dbo].[GEN_Gender] (
    GEN_ID bit not null,
    GEN_Gender varchar(42) not null,
    Metadata_GEN int not null,
    constraint pkGEN_Gender primary key (GEN_ID asc),
    constraint uqGEN_Gender unique (GEN_Gender)
)
    """.strip()

    assert result.sql == expected_sql
    assert result.comment == "Knot: Gender"
```

### Phase 2: Green (Make It Pass)

```python
# src/anchor_modeling_tool/generators/knots.py
def generate_knot_table(knot: Knot, metadata: Metadata) -> SQLStatement:
    """Generate CREATE TABLE for a knot"""
    table_name = f"[{metadata.encapsulation}].[{knot.mnemonic}_{knot.descriptor}]"
    id_col = f"{knot.mnemonic}_{metadata.identity_suffix}"
    value_col = f"{knot.mnemonic}_{knot.descriptor}"
    meta_col = f"{metadata.metadata_prefix}_{knot.mnemonic}"

    sql = f"""
CREATE TABLE {table_name} (
    {id_col} {knot.identity} not null,
    {value_col} {knot.data_range} not null,
    {meta_col} {metadata.metadata_type} not null,
    constraint pk{knot.mnemonic}_{knot.descriptor} primary key ({id_col} asc),
    constraint uq{knot.mnemonic}_{knot.descriptor} unique ({value_col})
)
    """.strip()

    return SQLStatement(sql=sql, comment=f"Knot: {knot.descriptor}")
```

### Phase 3: Refactor

Extract naming logic, improve formatting, etc.

## Implementation Phases

### Phase 1: Foundation (Core Types & Parsing)
1. Define core immutable types (Schema, Knot, Anchor, etc.)
2. Implement JSON parser
3. Implement YAML parser
4. Implement XML parser
5. Schema validation

### Phase 2: Naming Convention
1. Generic naming convention
2. SQL Server naming
3. PostgreSQL naming
4. Other database naming

### Phase 3: SQL Generation - Core (SQL Server Uni-temporal)
1. Knot table generation
2. Anchor table generation
3. Attribute table generation
4. Tie table generation
5. Basic constraints

### Phase 4: SQL Generation - Advanced Features
1. Nexus support
2. Natural key generation
3. Trigger generation
4. View generation (perspectives)
5. Schema tracking
6. Encryption support
7. Equivalence support

### Phase 5: Multi-Database Support
1. PostgreSQL generators
2. Oracle generators
3. Snowflake generators
4. Vertica generators

### Phase 6: Multi-Temporal Support
1. CRT (concurrent-reliance-temporal) generators
2. Bi-temporal generators (SQL Server only)

### Phase 7: Polish
1. SQL formatting/pretty-printing
2. Comments and documentation in SQL
3. CLI interface
4. Performance optimization

## Testing Strategy

### Unit Tests
- Each pure function tested in isolation
- Property-based testing for invariants (using hypothesis)
- Edge cases and error conditions

### Integration Tests
- Parse example.json → validate → name → generate → compare with example.sql
- Round-trip tests where possible

### Regression Tests
- Use existing test fixtures from external/anchor
- Compare output with original JavaScript implementation

### Test Organization

```
tests/
├── unit/
│   ├── test_parsers.py
│   ├── test_validation.py
│   ├── test_naming.py
│   └── test_generators/
│       ├── test_knots.py
│       ├── test_anchors.py
│       ├── test_attributes.py
│       ├── test_ties.py
│       └── ...
├── integration/
│   ├── test_end_to_end_sqlserver.py
│   ├── test_end_to_end_postgresql.py
│   └── ...
└── fixtures/
    ├── example.json
    ├── example.yaml
    ├── example.xml
    └── expected_outputs/
        ├── sqlserver_uni.sql
        ├── postgresql_uni.sql
        └── ...
```

## Error Handling Strategy

All functions that can fail return `Result[T, Error]`:

```python
@dataclass(frozen=True)
class ParseError:
    message: str
    line: Optional[int] = None
    column: Optional[int] = None

@dataclass(frozen=True)
class ValidationError:
    message: str
    path: str  # JSON path to problematic element

def parse_json(json_text: str) -> Result[Schema, ParseError]:
    """Parse JSON manifest to Schema"""
    ...

def validate_schema(schema: Schema) -> Result[Schema, list[ValidationError]]:
    """Validate schema invariants"""
    ...
```

## Configuration Management

Configuration is pure and explicit:

```python
@dataclass(frozen=True)
class GenerationConfig:
    """Configuration for SQL generation"""
    database_target: str
    temporalization: str
    metadata: Metadata
    # ... additional config

def load_config_from_dict(config_dict: dict) -> GenerationConfig:
    """Load configuration from dictionary"""
    ...

def merge_configs(base: GenerationConfig, override: GenerationConfig) -> GenerationConfig:
    """Merge configurations (override takes precedence)"""
    ...
```

## Performance Considerations

1. **Lazy evaluation**: Use generators/iterators where appropriate
2. **Memoization**: Cache naming convention results
3. **Parallel processing**: Generate independent sections in parallel (if needed)
4. **Structural sharing**: Frozen dataclasses and frozensets share structure

## Documentation Standards

1. Every public function has docstring with type signature and examples
2. Complex algorithms have inline comments explaining the approach
3. Architecture decisions documented in this file
4. API documentation generated from docstrings

## Migration Path from OOP to FP

Key transformations:

| OOP Pattern | FP Pattern |
|-------------|------------|
| Classes with methods | Pure functions + data |
| Mutable state | Immutable dataclasses |
| Inheritance | Composition + higher-order functions |
| Polymorphism | Pattern matching / function dispatch |
| Iterators with state | Generator functions |
| Null values | Option/Maybe type |
| Exceptions | Result type |
| Dependency injection | Function parameters |

## Success Criteria

1. ✅ All original features supported
2. ✅ All 50+ configuration options implemented
3. ✅ Output matches original JavaScript implementation
4. ✅ 100% type coverage (mypy --strict passes)
5. ✅ >95% test coverage
6. ✅ All functions are pure (no side effects)
7. ✅ All data structures immutable
8. ✅ TDD workflow followed throughout
