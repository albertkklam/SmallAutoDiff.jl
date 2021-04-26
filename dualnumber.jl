struct DualNumber
    real::Number
    dual::Number
end

Base.:+(dnum_left::DualNumber, dnum_right::DualNumber) = DualNumber(dnum_left.real + dnum_right.real, dnum_left.dual + dnum_right.dual)
Base.:+(dnum::DualNumber, num::Number) = DualNumber(dnum.real + num, dnum.dual)
Base.:+(num::Number, dnum::DualNumber) = Base.:+(dnum::DualNumber, num::Number)

Base.:-(dnum_left::DualNumber, dnum_right::DualNumber) = DualNumber(dnum_left.real - dnum_right.real, dnum_left.dual - dnum_right.dual)
Base.:-(dnum::DualNumber, num::Number) = DualNumber(dnum.real - num, dnum.dual)
Base.:-(num::Number, dnum::DualNumber) = DualNumber(num - dnum.real, dnum.dual)

Base.:*(dnum_left::DualNumber, dnum_right::DualNumber) = DualNumber(dnum_left.real * dnum_right.real, (dnum_left.dual * dnum_right.real) + (dnum_left.real * dnum_right.dual))
Base.:*(dnum::DualNumber, num::Number) = DualNumber(dnum.real * num, dnum.dual * num)
Base.:*(num::Number, dnum::DualNumber) = Base.:*(dnum::DualNumber, num::Number)

function Base.:/(dnum_left::DualNumber, dnum_right::DualNumber) 
    if dnum_right.real == 0
        throw(DivideError())
    else
        return DualNumber(dnum_left.real / dnum_right.real, (dnum_left.dual * dnum_right.real - dnum_left.real * dnum_right.dual) / (dnum_right.real ^ 2))
    end
end

function Base.:/(dnum::DualNumber, num::Number)
    if num == 0
        throw(DivideError())
    else
        return DualNumber(dnum.real / num, dnum.dual / num)
    end
end

function Base.:/(num::Number, dnum::DualNumber)
    if dnum.real == 0
        throw(DivideError())
    else
        return DualNumber(num / dnum.real, -(num * dnum.dual) / (dnum.real ^ 2))
    end
end

Base.:^(dnum_left::DualNumber, dnum_right::DualNumber) = DualNumber(dnum_left.real ^ dnum_right.real, dnum_left.real ^ (dnum_right.real - 1) * (dnum_left.real * dnum_right.dual * log(dnum_left.real) + (dnum_right.real * dnum_left.dual)))
Base.:^(dnum::DualNumber, num::Number) = DualNumber(dnum.real ^ num, dnum.dual * num * (dnum.real ^ (num - 1)))
Base.:^(num::Number, dnum::DualNumber) = DualNumber(num ^ dnum.real, (num ^ dnum.real) * dnum.dual * log(num))

Base.:(==)(dnum_left::DualNumber, dnum_right::DualNumber) = (dnum_left.real, dnum_left.dual) == (dnum_right.real, dnum_right.dual)
Base.:(==)(dnum::DualNumber, num::Number) = (dnum.real, dnum.dual) == (num, 0)
Base.:(==)(num::Number, dnum::DualNumber) = Base.:(==)(dnum::DualNumber, num::Number)

Base.:(!=)(dnum_left::DualNumber, dnum_right::DualNumber) = (dnum_left.real, dnum_left.dual) != (dnum_right.real, dnum_right.dual)
Base.:(!=)(dnum::DualNumber, num::Number) = (dnum.real, dnum.dual) != (num, 0)
Base.:(!=)(num::Number, dnum::DualNumber) = Base.:(!=)(dnum::DualNumber, num::Number)

Base.:<(dnum_left::DualNumber, dnum_right::DualNumber) = (dnum_left.real < dnum_right.real) | ((dnum_left.real == dnum_right.real) & (dnum_left.dual < dnum_right.dual))
Base.:<(dnum::DualNumber, num::Number) = (dnum.real < num) | ((dnum.real == num) & (dnum.dual < 0))
Base.:<(num::Number, dnum::DualNumber) = (num < dnum.real) | ((num == dnum.real) & (dnum.dual > 0))
Base.:>(dnum_left::DualNumber, dnum_right::DualNumber) = Base.:<(dnum_right::DualNumber, dnum_left::DualNumber)
Base.:>(dnum::DualNumber, num::Number) = Base.:<(num::Number, dnum::DualNumber)
Base.:>(num::Number, dnum::DualNumber) = Base.:<(dnum::DualNumber, num::Number)

Base.:(<=)(dnum_left::DualNumber, dnum_right::DualNumber) = Base.:<(dnum_left::DualNumber, dnum_right::DualNumber) | Base.:(==)(dnum_left::DualNumber, dnum_right::DualNumber)
Base.:(<=)(dnum::DualNumber, num::Number) = Base.:<(dnum::DualNumber, num::Number) | Base.:(==)(dnum::DualNumber, num::Number)
Base.:(<=)(num::Number, dnum::DualNumber) = Base.:<(num::Number, dnum::DualNumber) | Base.:(==)(num::Number, dnum::DualNumber)
Base.:(>=)(dnum_left::DualNumber, dnum_right::DualNumber) = Base.:>(dnum_left::DualNumber, dnum_right::DualNumber) | Base.:(==)(dnum_left::DualNumber, dnum_right::DualNumber)
Base.:(>=)(dnum::DualNumber, num::Number) = Base.:>(dnum::DualNumber, num::Number) | Base.:(==)(dnum::DualNumber, num::Number)
Base.:(>=)(num::Number, dnum::DualNumber) = Base:>(num::Number, dnum::DualNumber) | Base.:(==)(num::Number, dnum::DualNumber)