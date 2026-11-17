def empty_array_field($key):
    if has($key) then
        (.[$key] | type == "array" and length == 0)
    else
        true
    end;

def no_unknown:
    if type == "boolean" then
        . == false
    elif type == "object" or type == "array" then
        all(.[]; no_unknown)
    else
        false
    end;

def valid_resource:
    type == "object"
    and (.address | type == "string")
    and (.type | type == "string")
    and (.mode == "managed" or .mode == "data")
    and (.change | type == "object")
    and (.change.actions | type == "array")
    and (has("previous_address") | not)
    and (has("deposed") | not)
    and (.change | has("importing") | not);

def allowed_operational_drift:
    valid_resource

    and .mode == "managed"
    and .type == "vsphere_virtual_machine"
    and .address == "vsphere_virtual_machine.dev"
    and .provider_name == "registry.terraform.io/vmware/vsphere"
    and .name == "dev"
    and .change.actions == ["update"]

    and (.change.before | type == "object")
    and (.change.after | type == "object")

    and .change.before.name == "ubuntu-dev"
    and .change.after.name == "ubuntu-dev"

    and .change.before.id == "420c4cc8-44ae-6f44-9bad-92b82085802b"
    and .change.after.id == "420c4cc8-44ae-6f44-9bad-92b82085802b"

    and (
        (
            .change.before
            | del(
                .change_version,
                .guest_ip_addresses,
                .power_state,
                .vmware_tools_status
            )
        )
        ==
        (
            .change.after
            | del(
                .change_version,
                .guest_ip_addresses,
                .power_state,
                .vmware_tools_status
            )
        )
    )

    and (
        .change.after_unknown
        | type == "object" and no_unknown
    );

def valid_resource_drift:
    if has("resource_drift") then
        .resource_drift
        | type == "array"
        and length <= 1
        and all(.[]; allowed_operational_drift)
    else
        true
    end;

def allowed_dev_update:
    .mode == "managed"
    and .type == "vsphere_virtual_machine"
    and .address == "vsphere_virtual_machine.dev"
    and .provider_name == "registry.terraform.io/vmware/vsphere"
    and .name == "dev"
    and .change.actions == ["update"]

    and (.change.before | type == "object")
    and (.change.after | type == "object")

    and .change.before.name == "ubuntu-dev"
    and .change.after.name == "ubuntu-dev"

    and .change.before.id == "420c4cc8-44ae-6f44-9bad-92b82085802b"
    and .change.after.id == "420c4cc8-44ae-6f44-9bad-92b82085802b"

    and .change.before.memory == 1024
    and .change.after.memory == 2048

    and (
        (.change.before | del(.memory))
        ==
        (.change.after | del(.memory))
    )

    and (.change.after_unknown | type == "object")
    and (.change.after_unknown | no_unknown);

type == "object"

and (
    .format_version
    | if type == "string" then
        test("^1\\.[0-9]+$")
      else
        false
      end
)

and (.errored == false)
and (.complete == true)
and (.applyable | type == "boolean")
and (.resource_changes | type == "array")

and valid_resource_drift
and empty_array_field("deferred_changes")
and empty_array_field("action_invocations")

and (
    if has("output_changes") then
        .output_changes
        | type == "object"
        and all(.[]; .actions == ["no-op"])
    else
        true
    end
)

and all(.resource_changes[]; valid_resource)

and (
    [.resource_changes[] | .address] as $addresses
    |
    ($addresses | length)
    ==
    ($addresses | unique | length)
)

and (
    [
        .resource_changes[]
        | select(.change.actions != ["no-op"])
    ] as $changes
    |
    ($changes | length <= 1)
    and all($changes[]; allowed_dev_update)
    and (
        ($changes | length == 0)
        or (.applyable == true)
    )
)
