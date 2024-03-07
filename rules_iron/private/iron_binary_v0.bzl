"""To be described."""

def iron_binary_impl(ctx):
    """To be described."""
    quasi_binary_name = ctx.file.src.basename.rsplit(".", 1)[0]
    quasi_binary_output = actions.declare_file(quasi_binary_name)

    return [DefaultInfo(files = depset([quasi_binary_output]))]

iron_binary = rule(
    iron_binary_v0_impl,
    attrs = {
        src: ctx.attr.label(
            allow_single_file = [".fe"],
            mandatory = True,
        ),
    },
    executable = True,
)
