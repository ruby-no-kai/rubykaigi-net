const getSelectedRoleArn = () => {
  const roleArnSelector =
    document.querySelector<HTMLSelectElement>("#amc-roles-select");
  return roleArnSelector!.value;
};

const sendRequest = async function <T>(path: string, payload?: object) {
  const headers: { [key: string]: string } = {
    "x-requested-with": "amc-client",
    accept: "application/json, text/plain",
  };
  if (payload !== undefined)
    headers["content-type"] = "application/json; charset=utf-8";

  const resp = await fetch(path, {
    method: "POST",
    mode: "same-origin",
    cache: "no-cache",
    credentials: "include",
    headers: headers,
    body: payload !== undefined ? JSON.stringify(payload) : null,
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
  envchain_snippet_url: {
    url: string;
    data: string;
  };
};

document.querySelectorAll("div.actions-signin").forEach((elem) => {
  const form = elem.querySelector("form");
  if (!form) throw new Error("form");

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    enableSpinner();

    (async () => {
      const resp = await sendRequest<SigninResponse>("/api/signin", {
        role_arn: getSelectedRoleArn(),
      });

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
      const resp = await sendRequest<CredsResponse>("/api/creds", {
        role_arn: getSelectedRoleArn(),
      });

      const exportRaw = [
        `export AWS_ACCESS_KEY_ID='${resp.assume_role_response.credentials.access_key_id}'`,
        `export AWS_SECRET_ACCESS_KEY='${resp.assume_role_response.credentials.secret_access_key}'`,
        `export AWS_SESSION_TOKEN='${resp.assume_role_response.credentials.session_token}'`,
        "",
      ].join("\n");
      const exportMasked = [
        `export AWS_ACCESS_KEY_ID='${resp.assume_role_response.credentials.access_key_id}'`,
        `export AWS_SECRET_ACCESS_KEY='*******'`,
        `export AWS_SESSION_TOKEN='******'`,
        "",
      ].join("\n");
      document
        .querySelectorAll(
          ".creds-response-text.creds-response-type-export pre.creds-response-raw"
        )
        .forEach((pre) => {
          pre.innerHTML = exportRaw;
        });
      document
        .querySelectorAll(
          ".creds-response-text.creds-response-type-export pre.creds-response-masked"
        )
        .forEach((pre) => {
          pre.innerHTML = exportMasked;
        });

      const envchainRaw = [
        `curl -Ssf -d '${resp.envchain_snippet_url.data}' '${resp.envchain_snippet_url.url}' | envchain --set aws-rk AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN >/dev/null`,
        "",
      ].join("\n");
      const envchainMasked = [
        `curl -Ssf -d '*************************' '${resp.envchain_snippet_url.url}' | envchain --set aws-rk AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN >/dev/null`,
        "",
      ].join("\n");
      document
        .querySelectorAll(
          ".creds-response-text.creds-response-type-envchain pre.creds-response-raw"
        )
        .forEach((pre) => {
          pre.innerHTML = envchainRaw;
        });
      document
        .querySelectorAll(
          ".creds-response-text.creds-response-type-envchain pre.creds-response-masked"
        )
        .forEach((pre) => {
          pre.innerHTML = envchainMasked;
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
  .querySelectorAll<HTMLAnchorElement>(".creds-response-unmask a")
  .forEach((link) => {
    link.addEventListener("click", (e) => {
      e.preventDefault();
      const textEl = link.closest(".creds-response-text");
      if (!textEl) throw new Error("textEl");

      const dNone = textEl.querySelector("pre.d-none");
      const dDefault = textEl.querySelector("pre.d-default");

      if (!dNone) throw new Error("dNone");
      if (!dDefault) throw new Error("dDefault");

      dNone.classList.add("d-default");
      dNone.classList.remove("d-none");
      dDefault.classList.add("d-none");
      dDefault.classList.remove("d-default");
    });
  });
document
  .querySelectorAll<HTMLAnchorElement>(".creds-response-copy a")
  .forEach((link) => {
    link.addEventListener("click", (e) => {
      e.preventDefault();
      const textEl = link.closest(".creds-response-text");
      if (!textEl) throw new Error("textEl");
      const pre = textEl.querySelector<HTMLPreElement>(
        "pre.creds-response-raw"
      );
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
