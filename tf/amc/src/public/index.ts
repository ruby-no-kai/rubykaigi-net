const sendRequest = async function <T>(path: string) {
  const resp = await fetch(path, {
    method: "POST",
    mode: "same-origin",
    cache: "no-cache",
    credentials: "include",
    headers: { "x-requested-with": "amc-client" },
  });
  if (resp.ok) {
    return (await resp.json()) as T;
  } else {
    const contentType = resp.headers.get("content-type");
    if (contentType && contentType.match(/^application\/json(;.*)?$/)) {
      const json = await resp.json();
      console.error(json);
      throw new Error(
        `API ${path} returned ${resp.status}, ${JSON.stringify(json)}`
      );
    }
    throw new Error(`API ${path} returned ${resp.status}`);
  }
};
const handleError = (err: Error) => {
  console.error(err);
  alert(err);
  disableSpinner();
};

const enableSpinner = () => {
  document.querySelectorAll(".spinner").forEach((el) => {
    el.classList.remove("d-none");
    el.ariaLive = "polite";
  });

  document
    .querySelectorAll<HTMLFieldSetElement>(".amc-app fieldset")
    .forEach((el) => {
      el.disabled = true;
    });
};
const disableSpinner = () => {
  document.querySelectorAll(".spinner").forEach((el) => {
    el.classList.add("d-none");
    el.ariaLive = null;
  });
  document
    .querySelectorAll<HTMLFieldSetElement>(".amc-app fieldset")
    .forEach((el) => {
      el.disabled = false;
    });
};

type SigninResponse = {
  ok: boolean;
  signin_token: string;
  preferred_region: string;
};

type CredsResponse = {
  ok: boolean;
  preferred_region: string;
  assume_role_response: {
    credentials: {
      access_key_id: string;
      secret_access_key: string;
      session_token: string;
      expiration: string;
    };
  };
  envchain_snippet_url: string;
};

document.querySelectorAll("div.actions-signin").forEach((elem) => {
  const form = elem.querySelector("form");
  if (!form) throw new Error("form");

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    enableSpinner();

    (async () => {
      const resp = await sendRequest<SigninResponse>("/api/signin");

      const params = new URLSearchParams({
        Action: "login",
        Issuer: location.origin,
        Destination: `https://console.aws.amazon.com/console/home?region=${resp.preferred_region}`,
        SigninToken: resp.signin_token,
      });
      const url = `https://signin.aws.amazon.com/federation?${params.toString()}`;

      location.href = url;
    })().catch(handleError);
  });
});

document.querySelectorAll("div.actions-creds").forEach((elem) => {
  const form = elem.querySelector("form");
  const elemResults = document.getElementById("results");
  if (!form) throw new Error("form");
  if (!elemResults) throw new Error("results");

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    enableSpinner();
    document.querySelectorAll("div.creds-response").forEach((el) => {
      el.classList.add("d-none");
      el.ariaLive = "none";
    });

    (async () => {
      const resp = await sendRequest<CredsResponse>("/api/creds");

      document
        .querySelectorAll(".creds-response-text.creds-response-type-export pre")
        .forEach((pre) => {
          pre.innerHTML = [
            `export AWS_ACCESS_KEY_ID='${resp.assume_role_response.credentials.access_key_id}'`,
            `export AWS_SECRET_ACCESS_KEY='${resp.assume_role_response.credentials.secret_access_key}'`,
            `export AWS_SESSION_TOKEN='${resp.assume_role_response.credentials.session_token}'`,
            "",
          ].join("\n");
        });

      document
        .querySelectorAll(
          ".creds-response-text.creds-response-type-envchain pre"
        )
        .forEach((pre) => {
          pre.innerHTML = [
            `curl -Ssf '${resp.envchain_snippet_url}' | envchain --set aws-rk AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN >/dev/null`,
            "",
          ].join("\n");
        });
      document
        .querySelectorAll<HTMLAnchorElement>(
          ".creds-response-text.creds-response-type-envchain a.creds-response-url"
        )
        .forEach((a) => {
          a.href = resp.envchain_snippet_url;
        });

      document.querySelectorAll("div.creds-response").forEach((el) => {
        el.classList.remove("d-none");
        el.ariaLive = "assertive";
      });
      disableSpinner();
    })().catch(handleError);
  });
});

document
  .querySelectorAll<HTMLAnchorElement>(".creds-response-copy a")
  .forEach((link) => {
    link.addEventListener("click", (e) => {
      e.preventDefault();
      const textEl = link.closest(".creds-response-text");
      if (!textEl) throw new Error("textEl");
      const pre = textEl.querySelector("pre");
      if (!pre) throw new Error("pre");

      (async () => {
        const text = pre.innerText
          .split(/\n/)
          .map((v) => ` ${v}`)
          .join("\n")
          .replace(/^ $/, "");
        await navigator.clipboard.writeText(text);
        link.innerText = "Copied";
      })().catch(handleError);
    });
    link.addEventListener("mouseout", () => {
      link.innerText = "Copy";
    });
  });

document.body.classList.remove("amc-loading");
