export default {
  id: "local.tmux-bell",
  setup(context) {
    const ring = () => {
      Bun.spawn(["sh", "-c", "printf '\\a' > /dev/tty"], {
        stdin: "ignore",
        stdout: "ignore",
        stderr: "ignore",
      });
    };

    const sessionID = (event) =>
      event?.data?.sessionID ?? event?.properties?.sessionID;
    const isRoot = (id) => {
      if (!id) return false;
      const session = context.data.session.get(id);
      return !!session && !session.parentID;
    };

    const permissions = new Set();
    const forms = new Set();

    const stops = [
      // Lượt chạy kết thúc thành công.
      context.data.on("session.execution.succeeded", (event) => {
        if (isRoot(sessionID(event))) ring();
      }),

      // Lượt chạy kết thúc thất bại.
      context.data.on("session.execution.failed", (event) => {
        if (isRoot(sessionID(event))) ring();
      }),

      // Chỉ báo khi bị ngắt do treo/timeout; bỏ qua user/shutdown/superseded.
      context.data.on("session.execution.interrupted", (event) => {
        if (!isRoot(sessionID(event))) return;
        if (event?.data?.reason === "inactivity") ring();
      }),

      // Block: đang chờ cấp quyền.
      context.data.on("permission.asked", (event) => {
        const id = event?.data?.id;
        if (id && permissions.has(id)) return;
        if (id) permissions.add(id);
        if (sessionID(event)) ring();
      }),
      context.data.on("permission.replied", (event) => {
        permissions.delete(event?.data?.requestID);
      }),

      // Wait: OpenCode đang hỏi và chờ trả lời.
      context.data.on("form.created", (event) => {
        const id = event?.data?.form?.id;
        if (id && forms.has(id)) return;
        if (id) forms.add(id);
        if (event?.data?.form?.sessionID ?? sessionID(event)) ring();
      }),
      context.data.on("form.replied", (event) => {
        forms.delete(event?.data?.id);
      }),
      context.data.on("form.cancelled", (event) => {
        forms.delete(event?.data?.id);
      }),
    ];

    return () => {
      for (const stop of stops.reverse()) stop();
    };
  },
};
