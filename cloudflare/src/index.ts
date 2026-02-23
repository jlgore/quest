import { Container } from "@cloudflare/containers";

// #AI-DISCLOSURE claude helped me here because I was feeling eepy

interface Env {
  QUEST_CONTAINER: DurableObjectNamespace<QuestContainer>;
  SECRET_WORD: string;
}

export class QuestContainer extends Container<Env> {
  defaultPort = 3000;
  sleepAfter = "10m";
  pingEndpoint = "ping/healthz";

  // envVars are read at container start time — this.env is available
  // because field initializers run after super() sets it
  override envVars = {
    SECRET_WORD: this.env.SECRET_WORD,
  };

  override onStart(): void {
    console.log("Container started, SECRET_WORD injected");
  }

  override onStop(): void {
    console.log("Container stopped");
  }

  override onError(error: unknown): void {
    console.error("Container error:", error);
  }
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const id = env.QUEST_CONTAINER.idFromName("quest-app");
    const stub = env.QUEST_CONTAINER.get(id);
    return stub.fetch(request);
  },
};
