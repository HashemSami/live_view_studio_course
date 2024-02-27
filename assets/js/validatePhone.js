import { AsYouType } from "../vendor/libphonenumber-js.min";

const ValidatePhone = {
  mounted() {
    this.el.addEventListener("input", e => {
      // format phone number associated with the input field
      this.el.value = new AsYouType("US").input(this.el.value);
    });
  },
  destroyed() {
    // this.pickr.destroy();
  },
};

export default ValidatePhone;
