# Anchor Modeling Tool - Technical Specification

## 1. Executive Summary

This document specifies the functional requirements for the Anchor Modeling Tool, a Python-based system that converts anchor model manifests (XML/JSON/YAML) into SQL DDL scripts for multiple database platforms.

**Key Goals:**
- Support all features from the original JavaScript implementation
- Use functional programming (no OOP)
- Generate production-ready SQL with all temporal and audit capabilities
- Support 5+ database platforms with 3 temporal models each

## 2. Input Formats

### 2.1 XML Format

**Schema**: Based on `external/anchor/anchor.xsd`

**Root Element**: `<schema>`

**Key Elements**:

```xml
<schema>
  <metadata>
    <temporalization>uni</temporalization>
    <databaseTarget>SQLServer</databaseTarget>
    <!-- 50+ configuration options -->
  </metadata>

  <knot mnemonic="GEN" descriptor="Gender" identity="bit" dataRange="varchar(42)">
    <metadata>
      <capsule>dbo</capsule>
      <generator>false</generator>
    </metadata>
  </knot>

  <anchor mnemonic="PN" descriptor="Person" identity="int">
    <metadata>
      <capsule>dbo</capsule>
      <generator>true</generator>
    </metadata>
    <attribute mnemonic="NAM" descriptor="Name"
               timeRange="datetime" dataRange="varchar(42)">
      <metadata>
        <restatable>true</restatable>
      </metadata>
      <key stop="1" route="1st" of="PN" branch="1"/>
    </attribute>
    <identifier route="1st"/>
  </anchor>

  <tie timeRange="datetime">
    <role role="parent" type="AC" identifier="true"/>
    <role role="child" type="AC" identifier="true"/>
    <role role="having" type="PAT" identifier="true"/>
  </tie>

  <nexus mnemonic="EV" descriptor="Event" identity="int">
    <attribute mnemonic="DAT" descriptor="Date" dataRange="datetime"/>
    <role role="wasHeldAt" type="ST" identifier="false">
      <key stop="2" route="1st" of="EV" branch="2"/>
    </role>
    <identifier route="1st"/>
  </nexus>
</schema>
```

### 2.2 JSON Format

**Structure**: Flat object with nested maps

```json
{
  "schema": {
    "format": "0.99.16",
    "metadata": {
      "temporalization": "uni",
      "databaseTarget": "SQLServer",
      "identity": "int",
      "changingRange": "datetime"
    },
    "knot": {
      "GEN": {
        "mnemonic": "GEN",
        "descriptor": "Gender",
        "identity": "bit",
        "dataRange": "varchar(42)",
        "metadata": {
          "capsule": "dbo",
          "generator": "false"
        }
      }
    },
    "knots": ["GEN"],
    "anchor": {
      "PN": {
        "mnemonic": "PN",
        "descriptor": "Person",
        "identity": "int",
        "attribute": {
          "NAM": {
            "mnemonic": "NAM",
            "descriptor": "Name",
            "timeRange": "datetime",
            "dataRange": "varchar(42)",
            "key": {
              "PN|1st|1": {
                "stop": "1",
                "route": "1st",
                "of": "PN",
                "branch": "1"
              }
            }
          }
        },
        "attributes": ["NAM"]
      }
    },
    "anchors": ["PN"],
    "tie": {
      "AC_parent_AC_child_PAT_having": {
        "anchorRole": {
          "AC_parent": {
            "role": "parent",
            "type": "AC",
            "identifier": "true"
          }
        },
        "knotRole": {
          "PAT_having": {
            "role": "having",
            "type": "PAT",
            "identifier": "true"
          }
        }
      }
    }
  }
}
```

### 2.3 YAML Format

**Structure**: Human-readable equivalent of JSON

```yaml
schema:
  format: "0.99.16"
  metadata:
    temporalization: uni
    databaseTarget: SQLServer
  knot:
    GEN:
      mnemonic: GEN
      descriptor: Gender
      identity: bit
      dataRange: varchar(42)
```

## 3. Configuration Options (Metadata)

All 50+ configuration options from `Defaults.js`:

### 3.1 Identity & Metadata

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `identity` | string | `"int"` | Data type for surrogate keys |
| `identitySuffix` | string | `"ID"` | Suffix for ID columns |
| `metadataPrefix` | string | `"Metadata"` | Prefix for metadata columns |
| `metadataType` | string | `"int"` | Data type for metadata |
| `metadataUsage` | boolean | `true` | Enable metadata tracking |

### 3.2 Temporalization

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `temporalization` | enum | `"uni"` | uni/crt/bi |
| `changingRange` | string | `"datetime"` | Timestamp type for historization |
| `changingSuffix` | string | `"ChangedAt"` | Suffix for timestamp columns |
| `chronon` | string | `"datetime2(7)"` | Precise timestamp type |
| `now` | string | `"sysdatetime()"` | Current timestamp function |

### 3.3 Positor (Source Tracking)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `positGenerator` | boolean | `true` | Auto-generate positor |
| `positingRange` | string | `"datetime"` | Type for positing timestamps |
| `positingSuffix` | string | `"PositedAt"` | Suffix for positing columns |
| `positorRange` | string | `"tinyint"` | Type for positor identifier |
| `positorSuffix` | string | `"Positor"` | Suffix for positor columns |
| `positIdentity` | string | `"int"` | Identity type for posit tables |
| `positSuffix` | string | `"Posit"` | Suffix for posit tables |

### 3.4 Reliability

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `reliabilityRange` | string | `"decimal(5,2)"` | Type for reliability values |
| `reliabilitySuffix` | string | `"Reliability"` | Suffix for reliability columns |
| `defaultReliability` | string | `"1"` | Default reliability value |
| `deleteReliability` | string | `"0"` | Reliability for deletions |

### 3.5 Advanced Features

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `equivalence` | boolean | `false` | Support equivalent values |
| `equivalentSuffix` | string | `"EQ"` | Suffix for equivalence columns |
| `equivalentRange` | string | `"tinyint"` | Type for equivalence markers |
| `checksum` | boolean | `false` | MD5 checksums for large attributes |
| `checksumSuffix` | string | `"Checksum"` | Suffix for checksum columns |
| `encryption` | string | `""` | Encryption group name |
| `partitioning` | boolean | `false` | Partition tables by equivalence |
| `triggers` | boolean | `true` | Generate trigger-based enforcement |
| `businessViews` | boolean | `false` | Create business perspective views |
| `deletability` | boolean | `false` | Support soft deletes |
| `deletablePrefix` | string | `"Deletable"` | Prefix for deletable tables |
| `deletionSuffix` | string | `"Deleted"` | Suffix for deletion columns |
| `idempotency` | boolean | `false` | Idempotent inserts |
| `restatability` | boolean | `true` | Support historical restatement |
| `assertiveness` | boolean | `true` | Generate assertions |
| `assertionSuffix` | string | `"Assertion"` | Suffix for assertion columns |
| `privacy` | enum | `"Ignore"` | Privacy handling mode |
| `entityIntegrity` | boolean | `true` | Enforce entity integrity |
| `decisiveness` | boolean | `true` | Enforce decisiveness |

### 3.6 Database Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `databaseTarget` | enum | `"SQLServer"` | SQLServer/PostgreSQL/Oracle/Snowflake/Vertica |
| `encapsulation` | string | `"dbo"` | Database schema name |
| `naming` | enum | `"improved"` | improved/legacy naming convention |
| `knotAliases` | boolean | `false` | Use knot aliases |

### 3.7 Other Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dummySuffix` | string | `"Dummy"` | Suffix for dummy columns |
| `versionSuffix` | string | `"Version"` | Suffix for version columns |
| `statementTypeSuffix` | string | `"StatementType"` | Suffix for statement type |
| `annexSuffix` | string | `"Annex"` | Suffix for annex tables |

## 4. Output: SQL DDL

### 4.1 Database Support

**Tier 1 (Full Support)**:
- SQL Server: uni-temporal, crt, bi-temporal
- PostgreSQL: uni-temporal, crt

**Tier 2 (Partial Support)**:
- Oracle: uni-temporal, crt (limited)
- Snowflake: uni-temporal, crt (basic)
- Vertica: uni-temporal, crt (basic)

### 4.2 Generated SQL Sections

For **SQL Server uni-temporal**, the following sections are generated:

1. **CLR Functions** (SQL Server only)
   - MD5 hash function
   - Other utility functions

2. **Knots** (Reference Data)
   - CREATE TABLE statements
   - Primary key constraints
   - Unique constraints on values
   - Metadata column

3. **Anchors** (Entity Identity)
   - CREATE TABLE with identity column
   - Primary key constraint
   - Auto-increment if `generator=true`

4. **Attributes**
   - CREATE TABLE for each attribute
   - Foreign key to anchor/nexus
   - Temporal columns (if `timeRange` specified)
   - Knot reference (if `knotRange` specified)
   - Primary key (ID + ChangedAt for temporal)
   - Metadata column

5. **Ties** (Relationships)
   - CREATE TABLE with role columns
   - Foreign keys to anchors/knots/nexuses
   - Temporal columns (if `timeRange` specified)
   - Composite primary key
   - Metadata column

6. **Nexuses** (Relationship as Entity)
   - CREATE TABLE with identity
   - Attributes (like anchor)
   - Roles (like tie)

7. **Triggers**
   - Anchor insert triggers (immutability enforcement)
   - Attribute insert/update triggers (restatability, idempotency)
   - Tie triggers (relationship integrity)
   - Nexus triggers

8. **Natural Keys**
   - Views for composite natural keys
   - Key routing across attributes and ties
   - Branch support

9. **Key Generators**
   - Stored procedures for generating surrogate keys from natural keys
   - Optimized lookups

10. **Attribute Rewinders** (Time Travel)
    - Functions to retrieve attribute values at specific points in time

11. **Perspectives** (Business Views)
    - Anchor perspectives (denormalized views with all attributes)
    - Tie perspectives (join views)
    - Nexus perspectives

12. **Schema Tracking**
    - `_Schema` table: Stores executed schema XML
    - `_Anchor`, `_Attribute`, `_Tie`, `_Knot` views
    - Schema introspection and versioning

13. **Restatement Constraints**
    - Attribute restatement constraints
    - Tie restatement constraints

14. **Encryption**
    - Column encryption if `encryption` specified

15. **Descriptions**
    - Extended properties (SQL Server) or comments (PostgreSQL)

### 4.3 Example Output Structure

```sql
-- =========================================================
-- ANCHOR MODELING TOOL
-- Generated: 2026-01-20 10:30:00
-- Database: SQLServer
-- Temporalization: uni
-- =========================================================

-- =========================================================
-- KNOTS (Reference Data)
-- =========================================================

CREATE TABLE [dbo].[GEN_Gender] (
    GEN_ID bit not null,
    GEN_Gender varchar(42) not null,
    Metadata_GEN int not null,
    constraint pkGEN_Gender primary key (GEN_ID asc),
    constraint uqGEN_Gender unique (GEN_Gender)
);
GO

-- =========================================================
-- ANCHORS (Entity Identity)
-- =========================================================

CREATE TABLE [dbo].[PN_Person] (
    PN_ID int identity(1,1) not null,
    constraint pkPN_Person primary key (PN_ID asc)
);
GO

-- =========================================================
-- ATTRIBUTES
-- =========================================================

CREATE TABLE [dbo].[PN_NAM_Person_Name] (
    PN_NAM_PN_ID int not null,
    PN_NAM_Name varchar(42) not null,
    PN_NAM_ChangedAt datetime not null,
    Metadata_PN_NAM int not null,
    constraint fkPN_NAM_Person_Name foreign key (
        PN_NAM_PN_ID
    ) references [dbo].[PN_Person](PN_ID),
    constraint pkPN_NAM_Person_Name primary key (
        PN_NAM_PN_ID asc,
        PN_NAM_ChangedAt desc
    )
);
GO

-- ... continues for all constructs
```

## 5. Schema Constructs

### 5.1 Knot (Immutable Reference Data)

**Properties**:
- `mnemonic`: 2-3 letter code (e.g., "GEN")
- `descriptor`: Human-readable name (e.g., "Gender")
- `identity`: Data type for surrogate key
- `dataRange`: Data type for values
- `metadata`: Optional settings (generator, checksum, equivalent)

**Generated SQL**:
- Table: `{mnemonic}_{descriptor}`
- Columns: `{mnemonic}_ID`, `{mnemonic}_{descriptor}`, `Metadata_{mnemonic}`
- Constraints: Primary key on ID, unique on value

**Special Cases**:
- `checksum=true`: Add MD5 checksum column for large values
- `equivalent=true`: Add equivalence support
- `generator=false`: Manual ID assignment vs. auto-increment

### 5.2 Anchor (Entity Identity)

**Properties**:
- `mnemonic`: 2-3 letter code
- `descriptor`: Human-readable name
- `identity`: Data type for surrogate key
- `attributes`: Set of attributes
- `metadata`: Optional settings (generator)

**Generated SQL**:
- Table: `{mnemonic}_{descriptor}`
- Columns: `{mnemonic}_ID`
- One table per attribute (see 5.3)

**Immutability**: Anchor identities never change once created

### 5.3 Attribute (Property of Anchor/Nexus)

**Flavors**:
1. **Static**: No `timeRange` or `knotRange`
   - Value stored directly, never changes

2. **Historized**: Has `timeRange`
   - Values change over time
   - Multiple rows per entity (temporal history)

3. **Knotted**: Has `knotRange`
   - Value is foreign key to knot
   - Can be static or historized

**Properties**:
- `mnemonic`: Attribute code
- `descriptor`: Attribute name
- `dataRange`: Data type (for static/historized)
- `knotRange`: Knot mnemonic (for knotted)
- `timeRange`: Timestamp type (for historized)
- `keys`: Natural key components
- `metadata`: Settings (restatable, idempotent, deletable, privacy, checksum)

**Generated SQL**:
- Table: `{anchor_mnemonic}_{attribute_mnemonic}_{anchor_descriptor}_{attribute_descriptor}`
- Columns:
  - `{anchor}_{attr}_{anchor}_ID`: FK to anchor
  - `{anchor}_{attr}_{descriptor}`: Value (if dataRange)
  - `{anchor}_{attr}_{knot}_{descriptor}`: FK to knot (if knotRange)
  - `{anchor}_{attr}_ChangedAt`: Timestamp (if timeRange)
  - `Metadata_{anchor}_{attr}`: Metadata

**Primary Key**:
- Static: `(anchor_ID)`
- Historized: `(anchor_ID, ChangedAt DESC)`

**Special Features**:
- `restatable=true`: Allow historical values to be restated
- `idempotent=true`: Ignore duplicate inserts
- `deletable=true`: Support soft deletes
- `checksum=true`: MD5 for large values (geography, xml, etc.)

### 5.4 Tie (Relationship)

**Properties**:
- `roles`: 2+ roles connecting anchors/knots/nexuses
- `timeRange`: Optional temporalization
- `metadata`: Settings (restatable, deletable, idempotent)

**Role Properties**:
- `role`: Role name (e.g., "parent", "child")
- `type`: Mnemonic of anchor/knot/nexus
- `identifier`: Whether role is part of natural key
- `keys`: Natural key components

**Generated SQL**:
- Table: `{role1_type}_{role1_name}_{role2_type}_{role2_name}...`
- Columns:
  - For each role: `{type}_{role}_{type}_ID`
  - `{types}_ChangedAt` (if timeRange)
  - `Metadata_{types}`

**Primary Key**:
- Static tie: Composite of all identifier roles
- Historized tie: Composite of all identifier roles + ChangedAt DESC

**Constraints**:
- Foreign keys to all referenced entities
- Unique constraint on identifier roles

**Types of Ties**:
1. **Binary static**: 2 roles, no timeRange (e.g., Actor subset of Person)
2. **Binary historized**: 2 roles, timeRange (e.g., Stage playing Program over time)
3. **Ternary**: 3+ roles (e.g., Actor-Actor-ParentalType for parent-child relationships)

### 5.5 Nexus (Relationship as Entity)

**Properties**:
- `mnemonic`: Nexus code
- `descriptor`: Nexus name
- `identity`: Data type for surrogate key
- `attributes`: Set of attributes (like anchor)
- `roles`: Set of roles (like tie)
- `metadata`: Settings

**Generated SQL**:
- Table: `{mnemonic}_{descriptor}` (identity table)
- Attribute tables (one per attribute, like anchor attributes)
- Role columns in main table or separate tie tables

**Constraint**: Must have at least one anchor role (validated by XSD)

**Use Case**: When a relationship has attributes
- Example: Event (nexus) with Date attribute and "wasHeldAt" role to Stage

### 5.6 Natural Keys

**Properties**:
- `route`: Key name ("1st", "2nd", "3rd", etc.)
- `stop`: Position in route (1, 2, 3, ...)
- `branch`: Alternative path number
- `of`: Anchor/nexus mnemonic

**Key Components**:
- Attributes with keys
- Tie roles with keys

**Generated SQL**:
- View: `{anchor}_{route}` (e.g., `PE_1st`)
- Columns: All key components in stop order
- Joins: Attributes and ties in the route

**Example**:
```
Performance key route "1st":
  Stop 1: PE_DAT (Performance.Date attribute)
  Stop 2: PE_wasHeld (tie role to Stage)
  Stop 3: ST_at (other side of tie)
  Stop 4: ST_LOC (Stage.Location attribute)
  ...
```

## 6. Temporal Models

### 6.1 Uni-temporal (Single Time Dimension)

**Tracks**: When attribute values changed in the database

**Timestamp Column**: `{construct}_ChangedAt`

**Semantics**:
- Each row represents a value valid from ChangedAt until the next row's ChangedAt
- Latest value has the most recent ChangedAt

**Primary Key**: `(ID, ChangedAt DESC)`

**Example**:
```sql
-- Actor name changed twice
PN_ID  |  PN_NAM_Name  |  PN_NAM_ChangedAt
-------|---------------|------------------
1      |  'John Doe'   |  2020-01-01
1      |  'John Smith' |  2022-06-15
```

### 6.2 Concurrent-Reliance-Temporal (CRT)

**Tracks**:
- **Positing Time**: When information was recorded
- **Positor**: Source that recorded the information
- **Reliability**: Confidence in the information (0-1)

**Additional Columns**:
- `{construct}_PositedAt`: Timestamp when info was recorded
- `{construct}_Positor`: Source identifier
- `{construct}_Reliability`: Confidence value

**Semantics**:
- Multiple sources can provide conflicting information
- Each source's timeline is independent
- Reliability used to resolve conflicts

**Primary Key**: `(ID, Positor, PositedAt DESC)`

**Use Case**: Tracking information from multiple sources (sensors, auditors, etc.)

### 6.3 Bi-temporal (SQL Server Only)

**Tracks**:
- **Valid Time**: When fact was true in reality (uni-temporal)
- **Transaction Time**: When fact was recorded in database (system-versioned)

**Implementation**: Uses SQL Server temporal tables

**Columns**:
- `{construct}_ChangedAt`: Valid time
- System columns for transaction time (managed by SQL Server)

**Use Case**: Compliance, audit trails requiring both dimensions

## 7. Naming Conventions

### 7.1 Improved Naming (Default)

**Tables**:
- Knot: `{mnemonic}_{descriptor}` (e.g., `GEN_Gender`)
- Anchor: `{mnemonic}_{descriptor}` (e.g., `PN_Person`)
- Attribute: `{anchor}_{attr}_{anchor_desc}_{attr_desc}` (e.g., `PN_NAM_Person_Name`)
- Tie: `{role1_type}_{role1_name}_{role2_type}_{role2_name}...` (e.g., `AC_parent_AC_child_PAT_having`)

**Columns**:
- Identity: `{mnemonic}_ID`
- Value: `{mnemonic}_{descriptor}` or `{anchor}_{attr}_{descriptor}`
- Foreign key: `{target}_{role}_{target}_ID`
- Temporal: `{construct}_ChangedAt`
- Metadata: `Metadata_{construct}`

### 7.2 Legacy Naming

Uses shorter, less descriptive names (compatibility with old systems)

### 7.3 Database-Specific Rules

**SQL Server**:
- Square brackets: `[schema].[table]`
- Identity: `identity(1,1)`

**PostgreSQL**:
- Double quotes: `"schema"."table"`
- Serial: `SERIAL` or `BIGSERIAL`

**Oracle**:
- No quotes if names are valid identifiers
- Sequences for identity

## 8. Validation Rules

### 8.1 Schema-Level Validation

- All mnemonics must be unique within their type
- All descriptors must be unique within their type
- All table names (computed) must be unique
- All business names must be unique

### 8.2 Knot Validation

- Mnemonic: 2-5 characters, uppercase
- Must have dataRange
- Must have identity

### 8.3 Anchor Validation

- Mnemonic: 2-5 characters, uppercase
- Must have identity
- Attribute mnemonics unique within anchor

### 8.4 Attribute Validation

- Must have dataRange XOR knotRange (exactly one)
- If knotRange, must reference existing knot
- If timeRange, must be valid timestamp type for target DB

### 8.5 Tie Validation

- Must have at least 2 roles
- All role types must reference existing anchors/knots/nexuses
- At least one role must have identifier=true

### 8.6 Nexus Validation

- Must have at least one role
- At least one role must reference an anchor (not just knots)
- Attribute validation same as anchor attributes

### 8.7 Key Validation

- All keys with same route must form a valid path
- Stop numbers must be contiguous (1, 2, 3, ...)
- Key "of" must match containing anchor/nexus

## 9. Feature Matrix

| Feature | SQL Server | PostgreSQL | Oracle | Snowflake | Vertica |
|---------|-----------|-----------|--------|-----------|---------|
| Uni-temporal | ✅ | ✅ | ✅ | ✅ | ✅ |
| CRT | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Bi-temporal | ✅ | ❌ | ❌ | ❌ | ❌ |
| Triggers | ✅ | ✅ | ⚠️ | ❌ | ⚠️ |
| Business Views | ✅ | ✅ | ✅ | ✅ | ✅ |
| Natural Keys | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Encryption | ✅ | ⚠️ | ⚠️ | ❌ | ❌ |
| Partitioning | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Rewinders | ✅ | ✅ | ❌ | ❌ | ❌ |
| Schema Tracking | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Equivalence | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |

✅ = Full support
⚠️ = Partial/limited support
❌ = Not supported

## 10. API Specification

### 10.1 Core Functions

```python
# Parsing
def parse_json(json_text: str) -> Result[Schema, ParseError]
def parse_yaml(yaml_text: str) -> Result[Schema, ParseError]
def parse_xml(xml_text: str) -> Result[Schema, ParseError]

# Validation
def validate_schema(schema: Schema) -> Result[Schema, list[ValidationError]]

# Naming
def apply_naming(schema: Schema, metadata: Metadata) -> NamedSchema

# Generation
def generate_sql(
    named_schema: NamedSchema,
    config: GenerationConfig
) -> Result[SQLScript, GenerationError]

# Formatting
def format_sql(script: SQLScript) -> str

# End-to-End
def manifest_to_sql(
    manifest_text: str,
    format: Literal["json", "yaml", "xml"],
    config: GenerationConfig
) -> Result[str, Error]
```

### 10.2 CLI Interface

```bash
# Generate SQL from manifest
anchor-modeling-tool generate \
  --input example.json \
  --output example.sql \
  --database sqlserver \
  --temporalization uni

# Validate manifest
anchor-modeling-tool validate example.json

# Convert between formats
anchor-modeling-tool convert \
  --input example.xml \
  --output example.json \
  --format json
```

## 11. Testing Requirements

### 11.1 Unit Test Coverage

- Every public function has tests
- Edge cases: empty schemas, single elements, large schemas
- Error cases: invalid input, missing required fields
- Type coverage: All types exercised

### 11.2 Integration Tests

- Parse → Validate → Name → Generate → Format (end-to-end)
- All database targets
- All temporal models
- All major features enabled/disabled

### 11.3 Regression Tests

- Compare output with original JavaScript implementation
- Use test fixtures from `tests/fixtures/`

### 11.4 Property-Based Tests

- Schema roundtrip: parse(format(schema)) = schema
- Name uniqueness: No duplicate table/column names
- Key integrity: All keys form valid paths

### 11.5 Performance Tests

- Large schemas (100+ anchors, 1000+ attributes)
- Generation time < 1 second for typical schemas

## 12. Success Criteria

1. ✅ All input formats (XML/JSON/YAML) supported
2. ✅ All 50+ configuration options implemented
3. ✅ All database targets supported (tier 1 full, tier 2 partial)
4. ✅ All temporal models supported (uni/crt/bi)
5. ✅ All schema constructs supported (knot/anchor/attribute/tie/nexus)
6. ✅ Output matches original for SQL Server uni-temporal
7. ✅ 100% type coverage (mypy --strict)
8. ✅ >95% test coverage
9. ✅ All functions pure (no side effects)
10. ✅ All data immutable
11. ✅ TDD followed throughout
12. ✅ Documentation complete

## 13. Non-Goals (Out of Scope)

- Web UI (use existing `index.html`)
- Visual diagram layout
- Schema evolution/migration scripts
- Data loading/ETL
- Query generation
- Reporting

## 14. Dependencies

**Runtime**:
- Python 3.12+
- No external dependencies for core (stdlib only)
- Optional: `pyyaml` for YAML parsing, `lxml` for XML validation

**Development**:
- pytest
- mypy
- ruff (linting)
- pytest-cov
- hypothesis (property-based testing)

## 15. Performance Requirements

- Parse typical manifest (<100KB): < 100ms
- Generate SQL for typical schema (20 anchors, 100 attributes): < 500ms
- Memory usage: < 100MB for typical schema
- Support schemas up to 10MB manifest size

## 16. Deliverables

1. Python package: `anchor_modeling_tool`
2. Test suite with >95% coverage
3. Documentation (this spec + architecture + API docs)
4. CLI tool
5. Example usage
6. Migration guide from JavaScript version
